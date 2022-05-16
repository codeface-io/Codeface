import SwiftLSP

extension CodeSymbol
{
    func contains(line: Int) -> Bool
    {
        line >= lspDocumentSymbol.range.start.line
            && line <= lspDocumentSymbol.range.end.line
    }
}

struct CodeSymbol
{
    let lspDocumentSymbol: LSPDocumentSymbol
    let code: String
}
