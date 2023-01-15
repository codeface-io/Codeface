import Foundation
import SwiftLSP
import SwiftNodes

final class CodeFileArtifact: Identifiable, Sendable
{
    init(name: String, codeLines: [String])
    {
        self.name = name
        self.lines = codeLines
    }
    
    // MARK: - Tree Structure
    
    var symbolGraph = Graph<CodeArtifact.ID, CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    let name: String
    var code: String? { lines.joined(separator: "\n") }
    let lines: [String]
    
    let id = UUID().uuidString
}
