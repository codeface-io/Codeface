import SwiftLSP
import FoundationToolz

final class CodeFile: Codable, Sendable
{
    init(name: String,
         code: String,
         symbols: [CodeSymbol]? = nil)
    {
        self.name = name
        self.code = code
        self.symbols = symbols
    }
    
    let name: String
    
    var lines: [String] { code.lines }
    let code: String
    
    let symbols: [CodeSymbol]?
}
