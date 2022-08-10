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
func writeDependencyMetrics(toSymbolsInScope symbols: [CodeSymbolArtifact],
                            dependencies: Edges<CodeSymbolArtifact>)
{
    // find components within scope
    let graph = Graph(nodes: Set(symbols), edges: dependencies)
    let inScopeComponents = graph.findComponents()
    
    // sort components based on their external dependencies
    var componentsAndDependencyDiff: [(Set<CodeSymbolArtifact>, Int)] = inScopeComponents.map
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
            symbol.metrics.componentNumber = componentNumber
        }
    }
    
    // generate node ancestor numbers for each component
    for component in inScopeComponents
    {
        generateNumberOfAncestors(inComponent: component,
                                  dependencies: dependencies)
    }
    
    // write dependency difference
    for symbol in symbols
    {
        symbol.metrics.dependencyDifferenceScope =
            dependencies.outgoing(from: symbol).count
            - dependencies.ingoing(to: symbol).count
    }
}

@MainActor
func generateNumberOfAncestors(inComponent component: Set<CodeSymbolArtifact>,
                               dependencies: Edges<CodeSymbolArtifact>)
{
    var nodesToVisit = component
    
    while !nodesToVisit.isEmpty
    {
        nodesToVisit.first?.calculateNumberOfAncestors(nodesToVisit: &nodesToVisit,
                                                       dependencies: dependencies)
    }
}

extension CodeSymbolArtifact
{
    @MainActor
    func calculateNumberOfAncestors(nodesToVisit: inout Set<CodeSymbolArtifact>,
                                    dependencies: Edges<CodeSymbolArtifact>)
    {
        if !nodesToVisit.contains(self) { return } else { nodesToVisit -= self }
        
        let dependingSymbols = dependencies.ingoing(to: self).map { $0.source }
        
        metrics.numberOfAllIncomingDependenciesInScope = dependingSymbols.reduce(Int(0))
        {
            $1.calculateNumberOfAncestors(nodesToVisit: &nodesToVisit,
                                          dependencies: dependencies)
            
            return $0 + 1 + ($1.metrics.numberOfAllIncomingDependenciesInScope ?? 0)
        }
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
        hasher.combine(ObjectIdentifier(self))
    }
}
