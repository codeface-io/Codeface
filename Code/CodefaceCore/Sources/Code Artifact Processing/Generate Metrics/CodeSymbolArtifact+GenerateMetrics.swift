import SwiftyToolz

extension CodeSymbolArtifact
{
    func generateMetrics()
    {
        subsymbols.forEach { $0.generateMetrics() }
        
        generateSizeMetrics()
        generateDependencyMetrics()
    }
    
    private func generateSizeMetrics()
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
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toParts: subsymbols,
                               dependencies: subsymbolDependencies)
    }
}

@MainActor
func writeDependencyMetrics<Part>(toParts scopeParts: [Part],
                                  dependencies scopeDependencies: Edges<Part>)
    where Part: CodeArtifact & Hashable & Identifiable
{
    // write (random) component ranks
    let scopeGraph = Graph(nodes: Set(scopeParts), edges: scopeDependencies)
    let components = Array(scopeGraph.findComponents())
    
    for componentIndex in components.indices
    {
        let component = components[componentIndex]
        
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

extension CodeSymbolArtifact: Hashable
{
    public static func == (lhs: CodeSymbolArtifact,
                           rhs: CodeSymbolArtifact) -> Bool
    {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
