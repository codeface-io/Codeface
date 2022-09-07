import SwiftNodes

public extension CodeFolderArtifact
{
    func recursivelyPruneDependenciesAndCalculateDependencyMetrics()
    {
        // depth first! this is important
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
            case .file(let file):
                file.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
            }
        }
        
        partGraph.pruneDependenciesAndCalculateDependencyMetrics()
    }
}

private extension CodeFileArtifact
{
    func recursivelyPruneDependenciesAndCalculateDependencyMetrics()
    {
        symbolGraph.values.forEach { $0.recursivelyPruneDependenciesAndCalculateDependencyMetrics() }
        
        symbolGraph.pruneDependenciesAndCalculateDependencyMetrics()
    }
}

private extension CodeSymbolArtifact
{
    func recursivelyPruneDependenciesAndCalculateDependencyMetrics()
    {
        subsymbolGraph.values.forEach { $0.recursivelyPruneDependenciesAndCalculateDependencyMetrics() }
        
        subsymbolGraph.pruneDependenciesAndCalculateDependencyMetrics()
    }
}

private extension Graph where NodeValue: CodeArtifact & Identifiable
{
    mutating func pruneDependenciesAndCalculateDependencyMetrics()
    {
        // write component ranks by component size
        let components = findComponents()
        
        var componentsWithSize: [(Set<Node>, Int)] = components.map
        {
            ($0, $0.sum { $0.value.linesOfCode })
        }
        
        componentsWithSize.sort { $0.1 > $1.1 }
        
        for componentIndex in componentsWithSize.indices
        {
            let component = componentsWithSize[componentIndex].0
            
            for node in component
            {
                node.value.metrics.componentRank = componentIndex
            }
        }
        
        // analyze each component
        for component in components
        {
            let componentGraph = copy(includedValues: component.values())
            let componentCondensationGraph = componentGraph.makeCondensation()
            
            // write scc numbers sorted by topology
            let condensationNodesSortedByAncestors = componentCondensationGraph
                .findNumberOfNodeAncestors()
                .sorted { $0.1 < $1.1 }
                .map { $0.0 }
            
            for condensationNodeIndex in condensationNodesSortedByAncestors.indices
            {
                let condensationNode = condensationNodesSortedByAncestors[condensationNodeIndex]
                
                let condensationNodeContainsCycles = condensationNode.value.nodes.count > 1
                
                for sccNode in condensationNode.value.nodes
                {
                    sccNode.value.metrics.sccIndexTopologicallySorted = condensationNodeIndex
                    sccNode.value.metrics.isInACycle = condensationNodeContainsCycles
                }
            }
            
            // remove non-essential dependencies
            let minimumCondensationGraph = componentCondensationGraph.makeMinimumEquivalentGraph()
            
            for componentDependency in componentGraph.edges
            {
                // make sure this is a dependency between different condensation nodes and not with an SCC
                let source = componentDependency.source
                let target = componentDependency.target
                
                guard let sourceSCCIndex = source.value.metrics.sccIndexTopologicallySorted,
                      let targetSCCIndex = target.value.metrics.sccIndexTopologicallySorted
                else
                {
                    fatalError("At this point, artifacts shoud have their scc index set")
                }
                
                let isDependencyWithinSCC = sourceSCCIndex == targetSCCIndex
                
                if isDependencyWithinSCC { continue }
                
                // find the corresponding edge in the condensation graph
                let condensationSource = condensationNodesSortedByAncestors[sourceSCCIndex]
                let condensationTarget = condensationNodesSortedByAncestors[targetSCCIndex]
                let essentialEdge = minimumCondensationGraph.edge(from: condensationSource,
                                                                  to: condensationTarget)
                
                if essentialEdge == nil
                {
                    remove(componentDependency)
                }
            }
        }
    }
}
