import Foundation
import SwiftLSP
import SwiftNodes

class CodeFileArtifact: Identifiable
{
    init(name: String,
         codeLines: [String],
         scope: any CodeArtifact)
    {
        self.name = name
        self.lines = codeLines
        self.scope = scope
    }
    
    // MARK: - Metrics
    
    var metrics = Metrics()
    
    // MARK: - Tree Structure
    
    weak var scope: (any CodeArtifact)?
    var symbolGraph = Graph<CodeArtifact.ID, CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    let name: String
    var code: String? { lines.joined(separator: "\n") }
    let lines: [String]
    
    let id = UUID().uuidString
}
