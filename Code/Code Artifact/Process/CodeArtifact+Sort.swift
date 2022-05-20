import SwiftLSP

extension CodeArtifact
{
    func sort()
    {
        for part in parts
        {
            part.sort()
        }
        
        switch kind
        {
        case .folder:
            parts.sort { $0.linesOfCode > $1.linesOfCode }
            
        case .file, .symbol:
            parts.sort { $0.symbolPositionInFile < $1.symbolPositionInFile }
        }
    }
}

extension CodeArtifact
{
    var symbolPositionInFile: Int
    {
        symbol?.positionInFile ?? .max
    }
    
    var symbol: CodeSymbol?
    {
        guard case .symbol(let symbol) = kind else { return nil }
        return symbol
    }
}

extension CodeSymbol
{
    var positionInFile: Int
    {
        lspDocumentSymbol.range.start.line
    }
}
