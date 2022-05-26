import SwiftLSP

extension CodeSymbol
{
    static var kindNames: [String] { LSPDocumentSymbol.kindNames }
    
    func contains(line: Int) -> Bool
    {
        line >= lspDocumentSymbol.range.start.line
            && line <= lspDocumentSymbol.range.end.line
    }
}

struct CodeSymbol
{
    let lspDocumentSymbol: LSPDocumentSymbol
    let references: [LSPLocation]
    let code: String
}
