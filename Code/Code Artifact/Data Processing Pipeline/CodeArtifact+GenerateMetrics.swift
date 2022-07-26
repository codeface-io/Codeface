import SwiftyToolz

extension CodeArtifact
{
    func generateMetrics()
    {
        parts.forEach { $0.generateMetrics() }
            
        let locOfParts = parts.reduce(0) { $0 + $1.linesOfCode }
        
        parts.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfParts)
        }
        
        var loc: Int
        
        switch kind
        {
        case .folder:
            loc = locOfParts
            
        case .file(let codeFile):
            loc = codeFile.lines.count
        
        case .symbol(let symbol):
            let range = symbol.range
            loc = (range.end.line - range.start.line) + 1
        }
        
        metrics.linesOfCode = loc
        metrics.linesOfCodeWithoutParts = loc - locOfParts
    }
    
    var linesOfCode: Int
    {
        metrics.linesOfCode ?? 0
    }
}
