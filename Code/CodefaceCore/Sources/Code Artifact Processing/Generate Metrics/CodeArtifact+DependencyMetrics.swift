func writeDependencyMetrics<Part>(toParts scopeParts: [Part],
                                  dependencies scopeDependencies: inout Edges<Part>)
    where Part: CodeArtifact & Hashable & Identifiable
{
    // write component ranks by component size
    let scopeGraph = Graph(nodes: Set(scopeParts), edges: scopeDependencies)
    let components = scopeGraph.findComponents()
    
    var componentsWithSize: [(Set<Part>, Int)] = components.map
    {
        ($0, $0.sum { $0.linesOfCode })
    }
    
    componentsWithSize.sort { $0.1 > $1.1 }
    
    for componentIndex in componentsWithSize.indices
    {
        let component = componentsWithSize[componentIndex].0
        
        for part in component
        {
            part.metrics.componentRank = componentIndex
        }
    }
    
    // analyze each component
    for componentNodes in components
    {
        let componentDependencies = scopeDependencies.reduced(to: componentNodes)
        let componentGraph = Graph(nodes: componentNodes, edges: componentDependencies)
        
        let componentCondensationGraph = componentGraph.makeCondensation()
        
        // write scc numbers sorted by topology
        let condensationNodesSortedByAncestors = componentCondensationGraph
            .findNumberOfNodeAncestors()
            .sorted { $0.1 < $1.1 }
            .map { $0.0 }
        
        for condensationNodeIndex in condensationNodesSortedByAncestors.indices
        {
            let condensationNode = condensationNodesSortedByAncestors[condensationNodeIndex]
            
            for sccNode in condensationNode.stronglyConnectedComponent
            {
                sccNode.metrics.sccIndexTopologicallySorted = condensationNodeIndex
            }
        }
        
        // remove non-essential dependencies
        let minimumCondensationGraph = componentCondensationGraph.makeMinimumEquivalentGraph()
        
        for componentDependency in componentDependencies.all
        {
            // make sure this is a dependency between different condensation nodes and not with an SCC
            let source = componentDependency.source
            let target = componentDependency.target
            
            guard let sourceSCCIndex = source.metrics.sccIndexTopologicallySorted,
                  let targetSCCIndex = target.metrics.sccIndexTopologicallySorted
            else
            {
                fatalError("At this point, artifacts shoud have their scc index set")
            }
            
            let isDependencyWithinSCC = sourceSCCIndex == targetSCCIndex
            
            if isDependencyWithinSCC { continue }
            
            // find the corresponding edge in the condensation graph
            let condensationSource = condensationNodesSortedByAncestors[sourceSCCIndex]
            let condensationTarget = condensationNodesSortedByAncestors[targetSCCIndex]
            let condensationEdgeID = Edge.ID(source: condensationSource, target: condensationTarget)
            
            let isEssentialDependency = minimumCondensationGraph.edges.contains(condensationEdgeID)
            
            if !isEssentialDependency
            {
                scopeDependencies.remove(componentDependency)
            }
        }
    }
    
    // write numbers of dependencies
    for part in scopeParts
    {
        part.metrics.ingoingDependenciesInScope = scopeDependencies.ingoing(to: part).count
        part.metrics.outgoingDependenciesInScope = scopeDependencies.outgoing(from: part).count
    }
}
