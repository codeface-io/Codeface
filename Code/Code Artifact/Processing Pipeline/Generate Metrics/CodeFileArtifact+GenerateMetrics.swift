extension CodeFileArtifact
{
    func generateSizeMetrics()
    {
        symbols.forEach { $0.generateSizeMetrics() }
            
        let locOfAllSymbols = symbols.reduce(0) { $0 + $1.linesOfCode }
        
        symbols.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllSymbols)
        }
        
        metrics.linesOfCode = codeFile.lines.count
    }
    
    func generateDependencyMetrics()
    {
        guard !symbols.isEmpty else { return }
        
        symbols.forEach { $0.generateDependencyMetrics() }
        
        // find components within scope
        let inScopeComponents = findComponents(in: symbols)
        {
            $0.incomingDependenciesScope + $0.outgoingDependenciesScope
        }
        
        // write component numbers to symbol metrics
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
