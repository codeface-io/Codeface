import SwiftLSP

class CodeFile: Codable, Equatable
{
    static func == (lhs: CodeFile, rhs: CodeFile) -> Bool
    {
        lhs === rhs
    }
    
    init(name: String, uri: LSPDocumentUri, code: String)
    {
        self.name = name
        self.uri = uri
        self.code = code
    }
    
    let name: String
    let uri: LSPDocumentUri
    let code: String
    var lines: [String] { code.components(separatedBy: .newlines) }
    var symbols: [CodeSymbolData]? = nil
}
