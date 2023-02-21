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
    
    func code(in range: LSPRange) -> String?
    {
        let codeLines = lines
        
        guard codeLines.isValid(index: range.start.line),
              codeLines.isValid(index: range.end.line) else { return nil }
        
        return codeLines[range.start.line ... range.end.line].joined(separator: "\n")
    }
    
    var lines: [String] { code.lines }
    let code: String
    
    let symbols: [CodeSymbol]?
}
