import SwiftLSP
import Foundation
import SwiftyToolz

extension CodeSymbolArtifact: CodeArtifact
{
    public static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    public var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
}

@MainActor
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
    
    // MARK: - Tree Structure
    
    public weak var scope: CodeArtifact?
    
    public var subSymbols = [CodeSymbolArtifact]()
    
    // MARK: - Basics
    
    public let id = UUID().uuidString
    public let name: String
    public let kind: LSPDocumentSymbol.SymbolKind?
    public let range: LSPRange
    public let selectionRange: LSPRange
    public let code: String?
    
    public var dependencyDifferenceScope: Int
    {
        outgoingDependenciesScope.count - incomingDependenciesScope.count
    }
    
    public var incomingDependenciesScope = [String: Dependency]()
    public var outgoingDependenciesScope = [String: Dependency]()
    
    public var dependencyDifferenceExternal: Int
    {
        outgoingDependenciesExternal.count - incomingDependenciesExternal.count
    }
    
    public var incomingDependenciesExternal = [CodeSymbolArtifact]()
    public var outgoingDependenciesExternal = [CodeSymbolArtifact]()
}
