func writeDependencyMetrics<Part>(toScopeGraph scopeGraph: inout Graph<Part>)
    where Part: CodeArtifact & Hashable & Identifiable
{
    // write component ranks by component size
    let components = scopeGraph.findComponents()
    
    var componentsWithSize: [(Set<Node<Part>>, Int)] = components.map
    {
        ($0, $0.sum { $0.content.linesOfCode })
    }
    
    componentsWithSize.sort { $0.1 > $1.1 }
    
    for componentIndex in componentsWithSize.indices
    {
        let component = componentsWithSize[componentIndex].0
        
        for node in component
        {
            node.content.metrics.componentRank = componentIndex
        }
    }
    
    // analyze each component
    for componentNodes in components
    {
        let componentGraph = scopeGraph.reduced(to: componentNodes)
        let componentCondensationGraph = componentGraph.makeCondensation()
        
        // write scc numbers sorted by topology
        let condensationNodesSortedByAncestors = componentCondensationGraph
            .findNumberOfNodeAncestors()
            .sorted { $0.1 < $1.1 }
            .map { $0.0 }
        
        for condensationNodeIndex in condensationNodesSortedByAncestors.indices
        {
            let condensationNode = condensationNodesSortedByAncestors[condensationNodeIndex]
            
            let condensationNodeContainsCycles = condensationNode.content.stronglyConnectedComponent.count > 1
            
            for sccNode in condensationNode.content.stronglyConnectedComponent
            {
                sccNode.content.metrics.sccIndexTopologicallySorted = condensationNodeIndex
                sccNode.content.metrics.isInACycle = condensationNodeContainsCycles
            }
        }
        
        // remove non-essential dependencies
        let minimumCondensationGraph = componentCondensationGraph.makeMinimumEquivalentGraph()
        
        for componentDependency in componentGraph.edges
        {
            // make sure this is a dependency between different condensation nodes and not with an SCC
            let source = componentDependency.source
            let target = componentDependency.target
            
            guard let sourceSCCIndex = source.content.metrics.sccIndexTopologicallySorted,
                  let targetSCCIndex = target.content.metrics.sccIndexTopologicallySorted
            else
            {
                fatalError("At this point, artifacts shoud have their scc index set")
            }
            
            let isDependencyWithinSCC = sourceSCCIndex == targetSCCIndex
            
            if isDependencyWithinSCC { continue }
            
            // find the corresponding edge in the condensation graph
            let condensationSource = condensationNodesSortedByAncestors[sourceSCCIndex]
            let condensationTarget = condensationNodesSortedByAncestors[targetSCCIndex]
            let condensationEdgeID = Edge.ID(sourceContent: condensationSource.content,
                                             targetContent: condensationTarget.content)
            
            let isEssentialDependency = minimumCondensationGraph.hasEdge(condensationEdgeID)
            
            if !isEssentialDependency
            {
                scopeGraph.remove(componentDependency)
            }
        }
    }
    
    // write numbers of dependencies
    for partNode in scopeGraph.nodes
    {
        partNode.content.metrics.ingoingDependenciesInScope = scopeGraph.ancestors(of: partNode).count
        partNode.content.metrics.outgoingDependenciesInScope = scopeGraph.descandants(of: partNode).count
    }
}
