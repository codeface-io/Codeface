import SwiftyToolz

extension CodeArtifact
{
    // MARK: - Filter
    
    var filteredParts: [CodeArtifact]
    {
        parts.filter { $0.passesSearchFilter }
    }
    
    func updateSearchFilter(allPass: Bool)
    {
        if allPass || containsSearchTermRegardlessOfParts
        {
            passesSearchFilter = true
            
            for part in parts
            {
                part.updateSearchFilter(allPass: true)
            }
            
            return
        }
        
        passesSearchFilter = containsSearchTerm
        
        for part in parts
        {
            part.updateSearchFilter(allPass: false)
        }
    }
    
    // MARK: - Results
    
    @discardableResult
    func updateSearchResults(withSearchTerm searchTerm: String) -> Bool
    {
        if searchTerm == ""
        {
            containsSearchTermRegardlessOfParts = true
            partsContainSearchTerm = true
            
            for part in parts
            {
                part.updateSearchResults(withSearchTerm: searchTerm)
            }
            
            return true
        }
        
        containsSearchTermRegardlessOfParts = false
        partsContainSearchTerm = false
        
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
        
        for part in parts
        {
            if part.updateSearchResults(withSearchTerm: searchTerm)
            {
                partsContainSearchTerm = true
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
            
            if !parts.isEmpty
            {
                for part in parts
                {
                    matchesWithoutParts += part.assign(searchMatches: searchMatches)
                }
                
                matchesWithoutParts = Array(Set(matchesWithoutParts))
                
                if matchesWithoutParts.count < searchMatches.count
                {
                    partsContainSearchTerm = true
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
    
    var containsSearchTerm: Bool
    {
        partsContainSearchTerm || containsSearchTermRegardlessOfParts
    }
    
    private func contains(line: Int) -> Bool
    {
        switch kind
        {
        case.folder: return false
        case.file(let file): return file.lines.count > line
        case .symbol(let symbol): return symbol.contains(line: line)
        }
    }
}
