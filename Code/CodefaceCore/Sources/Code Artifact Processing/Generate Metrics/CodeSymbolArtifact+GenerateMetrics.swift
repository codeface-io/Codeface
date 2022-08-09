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
        $0.incomingDependenciesScope.values.map { $0.symbol }
        + $0.outgoingDependenciesScope.values.map { $0.symbol }
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
        generateNumberOfAncestors(inComponent: component)
    }
}

@MainActor
func generateNumberOfAncestors(inComponent component: SymbolSet)
{
    var nodesToVisit = component
    
    while !nodesToVisit.isEmpty
    {
        nodesToVisit.first?.calculateNumberOfAncestors(nodesToVisit: &nodesToVisit)
    }
}

extension CodeSymbolArtifact
{
    @MainActor
    func calculateNumberOfAncestors(nodesToVisit: inout SymbolSet)
    {
        if !nodesToVisit.contains(self) { return } else { nodesToVisit -= self }
        
        metrics.numberOfAllIncomingDependenciesInScope = incomingDependenciesScope.values.map { $0.symbol }.reduce(Int(0))
        {
            $1.calculateNumberOfAncestors(nodesToVisit: &nodesToVisit)
            
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
