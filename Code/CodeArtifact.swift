import SwiftLSP
import Foundation

/// debug
extension CodeArtifact
{
    func numberOfSymbols() -> Int
    {
        (parts ?? []).reduce(into: isSymbol ? 1 : 0)
        {
            num, part in num += part.numberOfSymbols()
        }
    }
    
    var isSymbol: Bool { if case .symbol = kind { return true } else { return false } }
}

/// helpers
extension CodeArtifact
{
    var symbol: LSPDocumentSymbol?
    {
        guard case .symbol(let symbol) = kind else { return nil }
        return symbol
    }
}

/// hashable
extension CodeArtifact: Hashable
{
    static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}

/// type
class CodeArtifact: Identifiable
{
    init(displayName: String, kind: Kind, parts: [CodeArtifact]? = nil)
    {
        self.displayName = displayName
        self.kind = kind
        self.parts = (parts?.isEmpty ?? true) ? nil : parts
    }
    
    let id = UUID().uuidString
    
    let displayName: String
    
    let kind: Kind
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(LSPDocumentSymbol) }
    
    var parts: [CodeArtifact]?
    
    var metrics: Metrics?
    
    struct Metrics
    {
        let linesOfCode: Int
    }
    
    var layout = Layout(width: 100, height: 50, centerX: 50, centerY: 25)
    
    struct Layout
    {
        let width: Double
        let height: Double
        let centerX: Double
        let centerY: Double
    }
}
