func writeDependencyMetrics<Part>(toParts scopeParts: [Part],
                                  dependencies scopeDependencies: Edges<Part>)
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
    
    // write topological ranks within components
    for componentNodes in components
    {
        let componentDependencies = scopeDependencies.reduced(to: componentNodes)
        let componentGraph = Graph(nodes: componentNodes, edges: componentDependencies)
        
        // set ranks
        let topologicalRanks = componentGraph.findTopologicalRanks()
        
        for (part, rank) in topologicalRanks
        {
            part.metrics.topologicalRankInComponent = rank
        }
    }
    
    // write numbers of dependencies
    for part in scopeParts
    {
        part.metrics.ingoingDependenciesInScope = scopeDependencies.ingoing(to: part).count
            
        part.metrics.outgoingDependenciesInScope = scopeDependencies.outgoing(from: part).count
    }
}
