import SwiftLSP

class CodeFile: Codable
{
    init(name: String, code: String)
    {
        self.name = name
        self.code = code
    }
    
    let name: String
    let code: String
    var lines: [String] { code.components(separatedBy: .newlines) }
    var symbols: [CodeSymbolData]? = nil
}
