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
            .map {
                return (
                    // the component itself
                    $0,
                    
                    // total lines of the component
                    $0.sum { $0.value.linesOfCode },
                    
                    // first line number (position in file) of the component
                    $0.min { $0.value.lineNumber ?? 0 } ?? 0
                )
            }
            .sorted
            {
                if $0.1 != $1.1 // if there is a size difference
                {
                    // bigger size wins
                    return $0.1 > $1.1
                }
                else if $0.2 != $1.2 // if the components differ in file position
                {
                    // components must contain symbols -> lower line number wins
                    return $0.2 < $1.2
                }
                else // this must be equally sized files/folders (super unlikely)
                {
                    // alphabetical order of name of first contained artifact
                    return ($0.0.first?.value.name ?? "") < ($1.0.first?.value.name ?? "")
                }
            }
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

public extension Collection
{
    func min<Number: Numeric & Comparable>(_ numberFromElement: (Element) -> Number) -> Number?
    {
        map(numberFromElement).min()
    }
    
    func min() -> Element? where Element: Comparable
    {
        var min: Element? = nil
        
        for element in self
        {
            
            guard let actualMin = min else
            {
                min = element
                continue
            }
            
            if element < actualMin
            {
                min = element
            }
        }
        
        return min
    }
}
