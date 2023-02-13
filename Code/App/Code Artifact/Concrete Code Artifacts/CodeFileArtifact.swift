import Foundation
import SwiftLSP
import SwiftNodes

final class CodeFileArtifact: Identifiable, Sendable
{
    init(name: String,
         codeLines: [String],
         symbolGraph: Graph<CodeArtifact.ID, CodeSymbolArtifact, Int>)
    {
        self.name = name
        self.lines = codeLines
        self.symbolGraph = symbolGraph
    }
    
    // MARK: - Tree Structure
    
    let symbolGraph: Graph<CodeArtifact.ID, CodeSymbolArtifact, Int>
    
    // MARK: - Basics
    
    let name: String
    var code: String? { lines.joined(separator: "\n") }
    let lines: [String]
    
    let id = UUID().uuidString
}
