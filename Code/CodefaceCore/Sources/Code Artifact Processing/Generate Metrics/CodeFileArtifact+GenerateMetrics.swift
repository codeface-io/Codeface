extension CodeFileArtifact
{
    func generateMetrics()
    {
        symbols.forEach { $0.generateMetrics() }
        
        generateSizeMetrics()
        generateDependencyMetrics()
    }
    
    private func generateSizeMetrics()
    {
        let locOfAllSymbols = symbols.reduce(0) { $0 + $1.linesOfCode }
        
        symbols.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllSymbols)
        }
        
        metrics.linesOfCode = codeFile.lines.count
    }
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toParts: symbols,
                               dependencies: symbolDependencies)
    }
}
