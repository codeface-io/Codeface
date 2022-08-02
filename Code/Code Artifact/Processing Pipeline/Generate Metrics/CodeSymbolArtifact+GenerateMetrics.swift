import SwiftyToolz

extension CodeSymbolArtifact
{
    func generateSizeMetrics()
    {
        subSymbols.forEach { $0.generateSizeMetrics() }
        
        let locOfAllSubsymbols = subSymbols.reduce(0) { $0 + $1.linesOfCode }
        
        subSymbols.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllSubsymbols)
        }
        
        let loc = (range.end.line - range.start.line) + 1
        
        metrics.linesOfCode = loc
    }
    
    func generateDependencyMetrics()
    {
        guard !subSymbols.isEmpty else { return }
        subSymbols.forEach { $0.generateDependencyMetrics() }
        generateDependencyMetricsInScope(with: subSymbols)
    }
}

@MainActor
func generateDependencyMetricsInScope(with symbols: [CodeSymbolArtifact])
{
    // find components within scope
    let inScopeComponents = findComponents(in: symbols)
    {
        $0.incomingDependenciesScope + $0.outgoingDependenciesScope
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
    static func == (lhs: CodeSymbolArtifact, rhs: CodeSymbolArtifact) -> Bool
    {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(ObjectIdentifier(self))
    }
}
