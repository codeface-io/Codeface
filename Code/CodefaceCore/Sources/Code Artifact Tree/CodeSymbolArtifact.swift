import SwiftLSP
import Foundation
import SwiftyToolz

extension CodeSymbolArtifact: CodeArtifact
{
    public func addDependency(from source: CodeArtifact,
                              to target: CodeArtifact)
    {
        guard let sourceSymbol = source as? CodeSymbolArtifact,
              let targetSymbol = target as? CodeSymbolArtifact
        else
        {
            log(error: "Tried to add dependency to symbol scope between non-symbol artifacts.")
            return
        }
        
        guard let sourceNode = subsymbols.first(where: { $0.content === sourceSymbol }),
              let targetNode = subsymbols.first(where: { $0.content === targetSymbol }) else {
            log(error: "Tried to add dependency to symbol scope between subsymbols that are not in scope")
            return
        }
        
        subsymbolDependencies.addEdge(from: sourceNode, to: targetNode)
    }
    
    public static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    public var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
}

public class CodeSymbolArtifact: Identifiable, ObservableObject
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
    
    public var subsymbolDependencies = Edges<CodeSymbolArtifact>()
    public var subsymbols = [Node<CodeSymbolArtifact>]()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let name: String
    public let kind: LSPDocumentSymbol.SymbolKind?
    public let range: LSPRange
    public let selectionRange: LSPRange
    public let code: String?
    public var references = [LSPLocation]()
}
