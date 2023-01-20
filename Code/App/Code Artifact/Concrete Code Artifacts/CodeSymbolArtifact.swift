import SwiftLSP
import SwiftNodes

final class CodeSymbolArtifact: Identifiable, Hashable, Sendable
{
    // MARK: - Initialization
    
    init(name: String,
         kind: LSPDocumentSymbol.SymbolKind?,
         range: LSPRange,
         selectionRange: LSPRange,
         code: String,
         subsymbolGraph: Graph<CodeArtifact.ID, CodeSymbolArtifact>)
    {
        self.name = name
        self.kind = kind
        self.range = range
        self.selectionRange = selectionRange
        self.code = code
        self.subsymbolGraph = subsymbolGraph
    }
    
    // MARK: - Graph Structure
    
    let subsymbolGraph: Graph<CodeArtifact.ID, CodeSymbolArtifact>
    
    // MARK: - Basics
    
    let id: CodeArtifact.ID = .randomID()
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind?
    let range: LSPRange
    let selectionRange: LSPRange
    let code: String?
}
