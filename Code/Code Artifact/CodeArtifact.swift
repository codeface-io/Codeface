import SwiftLSP
import Foundation

/// search
extension CodeArtifact
{
    func contains(searchTerm: String) -> Bool
    {
        if searchTerm == "" { return true }
        
        switch kind
        {
        case .folder(let folder):
            if folder.name.contains(searchTerm)
            {
                return true
            }
            
        case .file(let codeFile):
            if codeFile.name.contains(searchTerm)
                || codeFile.content.contains(searchTerm)
            {
                return true
            }
        
        case .symbol(let symbol):
            if symbol.lspDocumentSymbol.name.contains(searchTerm)
                || symbol.code.contains(searchTerm)
            {
                return true
            }
        }
        
        for part in (parts ?? [])
        {
            if part.contains(searchTerm: searchTerm)
            {
                return true
            }
        }
        
        return false
    }
}

/// display
extension CodeArtifact
{
    var secondaryDisplayName: String
    {
        switch kind
        {
        case .folder: return "Folder"
        case .file: return "File"
        case .symbol(let symbol): return symbol.lspDocumentSymbol.kindName
        }
    }
}

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
        return symbol.lspDocumentSymbol
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
@MainActor
class CodeArtifact: Identifiable, ObservableObject
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
    enum Kind { case folder(CodeFolder), file(CodeFile), symbol(CodeSymbol) }
    
    var parts: [CodeArtifact]?
    
    var metrics: Metrics?
    
    struct Metrics
    {
        let linesOfCode: Int
    }
    
    @Published var layout = Layout(width: 100, height: 50, centerX: 50, centerY: 25)
    
    struct Layout: Equatable
    {
        let width: Double
        let height: Double
        let centerX: Double
        let centerY: Double
    }
}
