import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    func calculateDependencyMetricsRecursively()
    {
        // depth first! this is important
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.calculateDependencyMetricsRecursively()
            case .file(let file):
                file.calculateDependencyMetricsRecursively()
            }
        }
        
        partGraph.calculateDependencyMetrics()
    }
}

@BackgroundActor
private extension CodeFileArtifact
{
    func calculateDependencyMetricsRecursively()
    {
        symbolGraph.values.forEach { $0.calculateDependencyMetricsRecursively() }
        
        symbolGraph.calculateDependencyMetrics()
    }
}

@BackgroundActor
private extension CodeSymbolArtifact
{
    func calculateDependencyMetricsRecursively()
    {
        subsymbolGraph.values.forEach { $0.calculateDependencyMetricsRecursively() }
        
        subsymbolGraph.calculateDependencyMetrics()
    }
}

@BackgroundActor
private extension Graph where NodeValue: CodeArtifact & Identifiable, NodeID == CodeArtifact.ID
{
    func calculateDependencyMetrics()
    {
        // write component ranks sorted by component size
        let sortedComponents = findComponents()
            .map { $0.compactMap({ node(with: $0) }) }
            .map { ($0, $0.sum { $0.value.linesOfCode }) }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }

        sortedComponents.forEachIndex
        {
            component, componentIndex in
            
            for node in component
            {
                node.value.metrics.componentRank = componentIndex
            }
        }

        // write cycle-related metrics (scc number, is part of cycle)
        for component in sortedComponents
        {
            let componentIDs = Set(component.map({ $0.id }))
            let componentGraph = filteredNodes(componentIDs)
            let componentCondensationGraph = componentGraph.makeCondensationGraph()

            // write scc numbers sorted by topology
            let sortedCondensationNodes = componentCondensationGraph
                .findNumberOfNodeAncestors()
                .sorted { $0.1 < $1.1 }
                .compactMap { componentCondensationGraph.node(with: $0.0) }

            sortedCondensationNodes.forEachIndex
            {
                condensationNode, condensationNodeIndex in

                let condensationNodeContainsCycles = condensationNode.value.nodeIDs.count > 1

                for nodeID in condensationNode.value.nodeIDs
                {
                    CodeArtifactMetricsCache.shared[nodeID].sccIndexTopologicallySorted = condensationNodeIndex
                    CodeArtifactMetricsCache.shared[nodeID].isInACycle = condensationNodeContainsCycles
                }
            }
        }
    }
}
