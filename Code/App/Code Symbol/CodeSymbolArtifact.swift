import SwiftLSP
import Foundation
import SwiftNodes

final class CodeSymbolArtifact: Identifiable, Hashable, Sendable
{
    // MARK: - Initialization
    
    init(name: String,
         kind: LSPDocumentSymbol.SymbolKind?,
         range: LSPRange,
         selectionRange: LSPRange,
         code: String,
         scope: any CodeArtifact)
    {
        self.name = name
        self.kind = kind
        self.range = range
        self.selectionRange = selectionRange
        self.code = code
        self.scope = .init(artifact: scope)
    }
    
    // MARK: - Graph Structure
    
    let scope: ScopeReference
    var subsymbolGraph = Graph<CodeArtifact.ID, CodeSymbolArtifact>()
    var outOfScopeDependencies = Set<CodeSymbolArtifact>()
    
    // MARK: - Basics
    
    let id = UUID().uuidString
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind?
    let range: LSPRange
    let selectionRange: LSPRange
    let code: String?
}
