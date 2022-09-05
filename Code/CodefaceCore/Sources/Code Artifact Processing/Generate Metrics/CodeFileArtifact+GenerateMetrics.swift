extension CodeFileArtifact
{
    func generateMetrics()
    {
        symbols.forEach { $0.content.generateMetrics() }
        
        generateSizeMetrics()
        generateDependencyMetrics()
    }
    
    private func generateSizeMetrics()
    {
        let locOfAllSymbols = symbols.sum { $0.content.linesOfCode }
        metrics.linesOfCodeOfParts = locOfAllSymbols
        
        symbols.forEach
        {
            $0.content.metrics.sizeRelativeToAllPartsInScope = Double($0.content.linesOfCode) / Double(locOfAllSymbols)
        }
        
        metrics.linesOfCode = codeFile.lines.count
    }
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toParts: symbols,
                               dependencies: &symbolDependencies)
    }
}
