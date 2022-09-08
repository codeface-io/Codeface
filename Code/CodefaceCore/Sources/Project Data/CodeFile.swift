import SwiftLSP

class CodeFile: Codable
{
    init(name: String, uri: LSPDocumentUri, lines: [String])
    {
        self.name = name
        self.uri = uri
        self.lines = lines
    }
    
    let name: String
    let uri: LSPDocumentUri
    var code: String { lines.joined(separator: "\n") }
    let lines: [String]
    var symbols = [CodeSymbolData]()
}
