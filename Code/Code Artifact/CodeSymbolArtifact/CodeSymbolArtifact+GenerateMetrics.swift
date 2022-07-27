extension CodeSymbolArtifact
{
    func generateMetrics()
    {
        subSymbols.forEach { $0.generateMetrics() }
        
        let locOfAllSubsymbols = subSymbols.reduce(0) { $0 + $1.linesOfCode }
        
        subSymbols.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllSubsymbols)
        }
        
        let loc = (range.end.line - range.start.line) + 1
        
        metrics.linesOfCode = loc
    }
}
