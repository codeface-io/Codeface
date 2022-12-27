import SwiftLSP
import FoundationToolz

public final class CodeFile: Codable, Sendable
{
    init(name: String, code: String, symbols: [CodeSymbolData]? = nil)
    {
        self.name = name
        self.code = code
        self.symbols = symbols
    }
    
    let name: String
    
    var lines: [String] { code.lines }
    let code: String
    
    let symbols: [CodeSymbolData]?
}
