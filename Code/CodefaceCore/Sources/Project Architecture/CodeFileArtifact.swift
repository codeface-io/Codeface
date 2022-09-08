import Foundation
import SwiftLSP
import SwiftNodes

public class CodeFileArtifact: Identifiable
{
    init(name: String,
         uri: LSPDocumentUri,
         codeLines: [String],
         scope: CodeArtifact)
    {
        self.name = name
        self.uri = uri
        self.lines = codeLines
        self.scope = scope
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Tree Structure
    
    public weak var scope: CodeArtifact?
    public var symbolGraph = Graph<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let name: String
    public let uri: LSPDocumentUri
    public var code: String? { lines.joined(separator: "\n") }
    let lines: [String]
    
    public let id = UUID().uuidString
}
