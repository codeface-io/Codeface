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
        generateDependencyMetricsInScope(with: subsymbols,
                                         dependencies: subsymbolDependencies)
    }
}

@MainActor
func generateDependencyMetricsInScope(with symbols: [CodeSymbolArtifact],
                                      dependencies: Edges<CodeSymbolArtifact>)
{
    // find components within scope
    let inScopeComponents = findComponents(in: symbols)
    {
        dependencies.outgoing(from: $0).map { $0.target }
        + dependencies.ingoing(to: $0).map { $0.source }
    }
    
    // sort components based on their external dependencies
    var componentsAndDependencyDiff: [(SymbolSet, Int)] = inScopeComponents.map
    {
        component in
        
        let componentDependencyDiffExternal = component.reduce(0)
        {
            $0 + $1.dependencyDifferenceExternal
        }
        
        return (component, componentDependencyDiffExternal)
    }
    
    componentsAndDependencyDiff.sort { $0.1 < $1.1 }
    
    // write component numbers to subsymbol metrics
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
func generateNumberOfAncestors(inComponent component: SymbolSet,
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
    func calculateNumberOfAncestors(nodesToVisit: inout SymbolSet,
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

@MainActor
func findComponents(in symbols: [CodeSymbolArtifact],
                    getNeighbours: (CodeSymbolArtifact) -> [CodeSymbolArtifact]) -> [SymbolSet]
{
    var symbolsToSearch = SymbolSet(symbols)
    var components = [SymbolSet]()
    
    while let symbolToSearch = symbolsToSearch.first
    {
        let nextComponent = symbolToSearch.findComponent(getNeighbours: getNeighbours)
        
        components += nextComponent
        
        symbolsToSearch -= nextComponent
    }
    
    return components
}

@MainActor
extension CodeSymbolArtifact
{
    func findComponent(getNeighbours: (CodeSymbolArtifact) -> [CodeSymbolArtifact]) -> SymbolSet
    {
        findComponentNodes(lackingIn: [], getNeighbours: getNeighbours)
    }
    
    private func findComponentNodes(lackingIn incompleteComponent: SymbolSet,
                                    getNeighbours: (CodeSymbolArtifact) -> [CodeSymbolArtifact]) -> SymbolSet
    {
        guard !incompleteComponent.contains(self) else { return [] }
        
        var lackingNodes: SymbolSet = [self]
        
        for neighbour in getNeighbours(self)
        {
            lackingNodes += neighbour.findComponentNodes(lackingIn: incompleteComponent + lackingNodes,
                                                         getNeighbours: getNeighbours)
        }
        
        return lackingNodes
    }
}

typealias SymbolSet = Set<CodeSymbolArtifact>

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
