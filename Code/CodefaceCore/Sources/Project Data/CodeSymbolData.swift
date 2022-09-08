import SwiftLSP
import SwiftyToolz

class CodeSymbolData: Codable
{
    init?(lspDocumentySymbol: LSPDocumentSymbol)
    {
        guard let decodedKind = lspDocumentySymbol.decodedKind else
        {
            log(error: "Could not decode LSP document symbol kind of value \(lspDocumentySymbol.kind)")
            return nil
        }
        
        name = lspDocumentySymbol.name
        kind = decodedKind
        range = lspDocumentySymbol.range
        selectionRange = lspDocumentySymbol.selectionRange
        children = lspDocumentySymbol.children.compactMap(CodeSymbolData.init)
    }
    
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind
    let range: LSPRange
    let selectionRange: LSPRange
    let children: [CodeSymbolData]
    var lspReferences = [LSPLocation]()
}
