import SwiftLSP
import SwiftyToolz

public extension CodeFile
{
    var code: String { lines.joined(separator: "\n") }
}

public class CodeFile: Codable
{
    init(name: String, path: String, lines: [String])
    {
        self.name = name
        self.path = path
        self.lines = lines
    }
    
    public let name: String
    public let path: String
    public let lines: [String]
    
    var symbols = [CodeSymbolData]()
}

class CodeSymbolData: Codable
{
    internal convenience init?(lspDocumentySymbol: LSPDocumentSymbol)
    {
        guard let kind = lspDocumentySymbol.decodedKind else
        {
            log(error: "Could not decode LSP document symbol kind of value \(lspDocumentySymbol.kind)")
            return nil
        }
        
        let children = lspDocumentySymbol.children.compactMap(CodeSymbolData.init)
        
        self.init(name: lspDocumentySymbol.name,
                  kind: kind,
                  range: lspDocumentySymbol.range,
                  selectionRange: lspDocumentySymbol.selectionRange,
                  children: children)
    }
    
    internal init(name: String,
                  kind: LSPDocumentSymbol.SymbolKind,
                  range: LSPRange,
                  selectionRange: LSPRange,
                  children: [CodeSymbolData] = [],
                  lspReferences: [LSPLocation] = [])
    {
        self.name = name
        self.kind = kind
        self.range = range
        self.selectionRange = selectionRange
        self.children = children
        self.lspReferences = lspReferences
    }
    
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind
    let range: LSPRange
    let selectionRange: LSPRange
    let children: [CodeSymbolData]
    var lspReferences = [LSPLocation]()
}
