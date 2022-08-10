import SwiftyToolz

extension CodeSymbolArtifact
{
    func generateSizeMetrics()
    {
        subsymbols.forEach { $0.generateSizeMetrics() }
        
        let locOfAllSubsymbols = subsymbols.reduce(0) { $0 + $1.linesOfCode }
        
        subsymbols.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllSubsymbols)
        }
        
        let loc = (range.end.line - range.start.line) + 1
        
        metrics.linesOfCode = loc
    }
    
    func generateDependencyMetrics()
    {
        guard !subsymbols.isEmpty else { return }
        subsymbols.forEach { $0.generateDependencyMetrics() }
        writeDependencyMetrics(toSymbolsInScope: subsymbols,
                               dependencies: subsymbolDependencies)
    }
}

@MainActor
func writeDependencyMetrics(toSymbolsInScope scopeSymbols: [CodeSymbolArtifact],
                            dependencies scopeDependencies: Edges<CodeSymbolArtifact>)
{
    let scopeGraph = Graph(nodes: Set(scopeSymbols), edges: scopeDependencies)
    
    // find components within scope
    let components = scopeGraph.findComponents()
    
    // sort components based on their external dependencies
    var componentsAndDependencyDiff: [(Set<CodeSymbolArtifact>, Int)] = components.map
    {
        component in
        
        let componentDependencyDiffExternal = component.reduce(0)
        {
            $0 + $1.dependencyDifferenceExternal
        }
        
        return (component, componentDependencyDiffExternal)
    }
    
    componentsAndDependencyDiff.sort { $0.1 < $1.1 }
    
    // write component numbers to symbol metrics
    for componentNumber in componentsAndDependencyDiff.indices
    {
        let component = componentsAndDependencyDiff[componentNumber].0
        
        for symbol in component
        {
            symbol.metrics.componentRank = componentNumber
        }
    }
    
    // write topological ranks within components to nodes
    for componentNodes in components
    {
        let componentEdges = scopeDependencies.reduced(to: componentNodes)
        let componentGraph = Graph(nodes: componentNodes, edges: componentEdges)
        
        let topologicalRanks = componentGraph.findTopologicalRanks()
        
        for (symbol, rank) in topologicalRanks
        {
            symbol.metrics.topologicalRankInComponent = rank
        }
    }
    
    // write numbers of dependencies
    for symbol in scopeSymbols
    {
        symbol.metrics.ingoingDependenciesInScope = scopeDependencies.ingoing(to: symbol).count
            
        symbol.metrics.outgoingDependenciesInScope = scopeDependencies.outgoing(from: symbol).count
    }
}

extension CodeSymbolArtifact: Hashable
{
    public static func == (lhs: CodeSymbolArtifact, rhs: CodeSymbolArtifact) -> Bool
    {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
