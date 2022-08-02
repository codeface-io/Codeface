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
        
        // find components within scope
        let inScopeComponents = findComponents(in: subSymbols)
        {
            $0.incomingDependenciesScope + $0.outgoingDependenciesScope
        }
        
        // write component numbers to subsymbol metrics
        for componentNumber in inScopeComponents.indices
        {
            let component = inScopeComponents[componentNumber]
            
            for symbol in component
            {
                symbol.metrics.componentNumber = componentNumber
            }
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
