import SwiftLSP
import FoundationToolz

/**
 ⛔️ Do not change! This is part of the ".codebase" file format.
 */
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
