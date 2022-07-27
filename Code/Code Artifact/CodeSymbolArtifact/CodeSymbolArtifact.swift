import SwiftLSP
import Foundation
import SwiftyToolz

extension CodeSymbolArtifact
{
    static var kindNames: [String] { LSPDocumentSymbol.SymbolKind.names }
    
    func contains(line: Int) -> Bool
    {
        line >= range.start.line && line <= range.end.line
    }
}

extension CodeSymbolArtifact
{
    var positionInFile: Int
    {
        range.start.line
    }
    
    var kindName: String { kind?.name ?? "Unknown Kind of Symbol" }
}

@MainActor
class CodeSymbolArtifact: Identifiable, ObservableObject
{
    // Mark: - Initialization
    
    init(name: String,
         kind: LSPDocumentSymbol.SymbolKind?,
         range: LSPRange,
         references: [LSPLocation],
         code: String,
         scope: Scope)
    {
        self.name = name
        self.kind = kind
        self.range = range
        self.references = references
        self.code = code
        self.scope = scope
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Tree Structure
    
    var scope: Scope
    
    enum Scope
    {
        case file(Weak<CodeFileArtifact>)
        case symbol(Weak<CodeSymbolArtifact>)
    }
    
    var subSymbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    let id = UUID().uuidString
    let name: String
    let kind: LSPDocumentSymbol.SymbolKind?
    let range: LSPRange
    let references: [LSPLocation]
    let code: String?
}
