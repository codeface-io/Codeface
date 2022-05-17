import SwiftLSP
import Foundation
import SwiftyToolz

/// search
extension CodeArtifact
{
    @discardableResult
    func updateSearchResults(withSearchTerm searchTerm: String) -> Bool
    {
        containsSearchTermRegardlessOfParts = false
        partsContainsSearchTerm = false
        
        if searchTerm == ""
        {
            containsSearchTermRegardlessOfParts = true
            partsContainsSearchTerm = true
            
            for part in (parts ?? [])
            {
                part.updateSearchResults(withSearchTerm: searchTerm)
            }
            
            return true
        }
        
        switch kind
        {
        case .folder(let folder):
            if folder.name.contains(searchTerm)
            {
                containsSearchTermRegardlessOfParts = true
            }
            
        case .file(let codeFile):
            // regular search
            if codeFile.name.contains(searchTerm)
            {
                containsSearchTermRegardlessOfParts = true
            }
            
            // search in code, then assign these matches recursively to parts
            var allMatches = [Int]()
            
            for lineIndex in 0 ..< codeFile.lines.count
            {
                if codeFile.lines[lineIndex].contains(searchTerm)
                {
                    allMatches += lineIndex
                }
            }
            
            assign(searchMatches: allMatches)
            
        case .symbol(let symbol):
            if symbol.lspDocumentSymbol.name.contains(searchTerm)
            {
                containsSearchTermRegardlessOfParts = true
            }
        }
        
        for part in (parts ?? [])
        {
            if part.updateSearchResults(withSearchTerm: searchTerm)
            {
                partsContainsSearchTerm = true
            }
        }
        
        return containsSearchTerm
    }
    
    @discardableResult
    private func assign(searchMatches: [Int]) -> [Int]
    {
        switch kind
        {
        case .file, .symbol:
            var matchesWithoutParts = [Int]()
            
            if let parts = parts, !parts.isEmpty
            {
                for part in parts
                {
                    matchesWithoutParts += part.assign(searchMatches: searchMatches)
                }
                
                matchesWithoutParts = Array(Set(matchesWithoutParts))
                
                if matchesWithoutParts.count < searchMatches.count
                {
                    partsContainsSearchTerm = true
                }
            }
            else
            {
                matchesWithoutParts = searchMatches
            }
            
            let matchesNotInSelf = matchesWithoutParts.filter
            {
                !contains(line: $0)
            }
            
            if matchesNotInSelf.count < matchesWithoutParts.count
            {
                containsSearchTermRegardlessOfParts = true
            }
            
            return matchesNotInSelf
            
        case .folder: return []
        }
    }
    
    func contains(line: Int) -> Bool
    {
        switch kind
        {
        case.folder: return false
        case.file(let file): return file.lines.count > line
        case .symbol(let symbol): return symbol.contains(line: line)
        }
    }
    
    func updateSearchFilter(allPass: Bool)
    {
        if allPass || containsSearchTermRegardlessOfParts
        {
            passesSearchFilter = true
            
            for part in (parts ?? [])
            {
                part.updateSearchFilter(allPass: true)
            }
            
            return
        }
        
        passesSearchFilter = containsSearchTerm
        
        for part in (parts ?? [])
        {
            part.updateSearchFilter(allPass: false)
        }
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
    
    // search filter
    
    @Published var passesSearchFilter = true
    
    var containsSearchTerm: Bool
    {
        partsContainsSearchTerm || containsSearchTermRegardlessOfParts
    }
    
    var partsContainsSearchTerm = true
    var containsSearchTermRegardlessOfParts = true
}
