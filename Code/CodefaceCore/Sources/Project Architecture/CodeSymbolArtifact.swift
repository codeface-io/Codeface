import SwiftLSP
import Foundation
import SwiftNodes

public class CodeSymbolArtifact: Identifiable, Hashable
{
    // MARK: - Initialization
    
    public init(name: String,
                kind: LSPDocumentSymbol.SymbolKind?,
                range: LSPRange,
                selectionRange: LSPRange,
                code: String,
                scope: CodeArtifact)
    {
        self.name = name
        self.kind = kind
        self.range = range
        self.selectionRange = selectionRange
        self.code = code
        self.scope = scope
    }
    
    // MARK: - Metrics
    
    public var metrics = Metrics()
    
    // MARK: - Graph Structure
    
    public weak var scope: CodeArtifact?
    public var subsymbolGraph = Graph<CodeSymbolArtifact>()
    public var outOfScopeDependencies = Set<CodeSymbolArtifact>()
    
    // MARK: - Hashability
    
    public static func == (lhs: CodeSymbolArtifact,
                           rhs: CodeSymbolArtifact) -> Bool { lhs === rhs }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let name: String
    public let kind: LSPDocumentSymbol.SymbolKind?
    public let range: LSPRange
    public let selectionRange: LSPRange
    public let code: String?
}
