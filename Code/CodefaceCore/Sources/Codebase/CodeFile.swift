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
    
    // TODO: this URI should not be part of the file format. we only need it to retrieve the data, we don't even need file IDs in the storage format ...
    let uri: LSPDocumentUri
    let code: String
    var lines: [String] { code.components(separatedBy: .newlines) }
    var symbols: [CodeSymbolData]? = nil
}
