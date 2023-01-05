import Foundation
import SwiftLSP
import SwiftNodes

final class CodeFileArtifact: Identifiable, Sendable
{
    init(name: String,
         codeLines: [String],
         scope: any CodeArtifact)
    {
        self.name = name
        self.lines = codeLines
        self.scope = .init(artifact: scope)
    }
    
    // MARK: - Tree Structure
    
    let scope: ScopeReference
    var symbolGraph = Graph<CodeArtifact.ID, CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    let name: String
    var code: String? { lines.joined(separator: "\n") }
    let lines: [String]
    
    let id = UUID().uuidString
}
