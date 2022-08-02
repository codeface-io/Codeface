import SwiftLSP
import Foundation
import SwiftyToolz

extension CodeSymbolArtifact: CodeArtifact
{
    static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
}

@MainActor
class CodeSymbolArtifact: Identifiable, ObservableObject
{
    // Mark: - Initialization
    
    init(name: String,
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
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Tree Structure
    
    weak var scope: CodeArtifact?
    
    var subSymbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    let id = UUID().uuidString
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind?
    let range: LSPRange
    let selectionRange: LSPRange
    let code: String?
    
    var dependencyDifferenceScope: Int
    {
        outgoingDependenciesScope.count - incomingDependenciesScope.count
    }
    
    var incomingDependenciesScope = [CodeSymbolArtifact]()
    var outgoingDependenciesScope = [CodeSymbolArtifact]()
    
    var dependencyDifferenceExternal: Int
    {
        outgoingDependenciesExternal.count - incomingDependenciesExternal.count
    }
    
    var incomingDependenciesExternal = [CodeSymbolArtifact]()
    var outgoingDependenciesExternal = [CodeSymbolArtifact]()
}
