import SwiftLSP
import Foundation
import SwiftNodes
import SwiftyToolz

extension CodeSymbolArtifact: Hashable
{
    public static func == (lhs: CodeSymbolArtifact,
                           rhs: CodeSymbolArtifact) -> Bool
    {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}

extension CodeSymbolArtifact: CodeArtifact
{
    public func sort()
    {
        subsymbolGraph.sort(by: <)
    }
    
    public var parts: [CodeArtifact]
    {
        subsymbolGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addDependency(from source: CodeArtifact,
                              to target: CodeArtifact)
    {
        subsymbolGraph.addEdge(from: source.id, to: target.id)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { (range.end.line - range.start.line) + 1 }
    
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
    
    public var subsymbolGraph = Graph<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let name: String
    public let kind: LSPDocumentSymbol.SymbolKind?
    public let range: LSPRange
    public let selectionRange: LSPRange
    public let code: String?
    public var references = [LSPLocation]()
}
