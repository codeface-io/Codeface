import SwiftLSP

extension CodeSymbol
{
    var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
    
    static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    func contains(line: Int) -> Bool
    {
        line >= range.start.line && line <= range.end.line
    }
}

struct CodeSymbol: Codable
{
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind?
    let range: LSPRange
    let references: [LSPLocation]
    let code: String
}
