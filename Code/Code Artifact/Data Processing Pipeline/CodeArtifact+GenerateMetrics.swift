import SwiftyToolz

extension CodeFolderArtifact
{
    func generateMetrics()
    {
        subfolders.forEach { $0.generateMetrics() }
        files.forEach { $0.generateMetrics() }
            
        let locOfParts = parts.reduce(0) { $0 + $1.linesOfCode }
        
        parts.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfParts)
        }
        
        metrics.linesOfCode = locOfParts
    }
}

extension CodeFileArtifact
{
    func generateMetrics()
    {
        symbols.forEach { $0.generateMetrics() }
            
        let locOfAllSymbols = symbols.reduce(0) { $0 + $1.linesOfCode }
        
        symbols.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllSymbols)
        }
        
        metrics.linesOfCode = codeFile.lines.count
    }
}

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
        
        let range = codeSymbol.range
        let loc = (range.end.line - range.start.line) + 1
        
        metrics.linesOfCode = loc
    }
}

extension CodeArtifact
{
    var linesOfCode: Int
    {
        metrics.linesOfCode ?? 0
    }
}
