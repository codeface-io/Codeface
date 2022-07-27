import SwiftyToolz

extension ArtifactViewModel
{
    // MARK: - Filter
    
    var filteredParts: [ArtifactViewModel]
    {
        (children ?? []).filter { $0.codeArtifact.passesSearchFilter }
    }
    
    func updateSearchFilter(allPass: Bool)
    {
        // TODO: reproduce search
//        guard let containsSearchTermRegardlessOfParts = containsSearchTermRegardlessOfParts,
//              let partsContainSearchTerm = partsContainSearchTerm else
//        {
//            passesSearchFilter = true
//
//            for part in parts
//            {
//                part.updateSearchFilter(allPass: allPass)
//            }
//
//            return
//        }
//
//        if allPass || containsSearchTermRegardlessOfParts
//        {
//            passesSearchFilter = true
//
//            for part in parts
//            {
//                part.updateSearchFilter(allPass: true)
//            }
//
//            return
//        }
//
//        passesSearchFilter = partsContainSearchTerm
//
//        for part in parts
//        {
//            part.updateSearchFilter(allPass: false)
//        }
    }
    
    // MARK: - Results
    
//    @discardableResult
//    func updateSearchResults(withSearchTerm searchTerm: String) -> Bool
//    {
//        if searchTerm == ""
//        {
//            containsSearchTermRegardlessOfParts = nil
//            partsContainSearchTerm = nil
//
//            for part in parts
//            {
//                part.updateSearchResults(withSearchTerm: searchTerm)
//            }
//
//            return true
//        }
//
//        containsSearchTermRegardlessOfParts = false
//        partsContainSearchTerm = false
//
//        for part in parts
//        {
//            if part.updateSearchResults(withSearchTerm: searchTerm)
//            {
//                partsContainSearchTerm = true
//            }
//        }
//
//        if name.contains(searchTerm)
//        {
//            containsSearchTermRegardlessOfParts = true
//        }
//
//        if kindName.contains(searchTerm)
//        {
//            containsSearchTermRegardlessOfParts = true
//        }
//
//        switch kind
//        {
//        case .folder, .symbol:
//            break
//
//        case .file(let codeFile):
//            // search in code, then assign these matches recursively to parts
//            var allMatches = [Int]()
//
//            for lineIndex in 0 ..< codeFile.lines.count
//            {
//                if codeFile.lines[lineIndex].contains(searchTerm)
//                {
//                    allMatches += lineIndex
//                }
//            }
//
//            assign(searchMatches: allMatches)
//        }
//
//        return partsContainSearchTerm ?? false || containsSearchTermRegardlessOfParts ?? false
//    }
//
//    @discardableResult
//    private func assign(searchMatches: [Int]) -> [Int]
//    {
//        switch kind
//        {
//        case .file, .symbol:
//            var matchesWithoutParts = searchMatches
//
//            for part in parts
//            {
//                matchesWithoutParts = part.assign(searchMatches: matchesWithoutParts)
//            }
//
//            if matchesWithoutParts.count < searchMatches.count
//            {
//                partsContainSearchTerm = true
//            }
//
//            let matchesNotInSelf = matchesWithoutParts.filter
//            {
//                !contains(line: $0)
//            }
//
//            if matchesNotInSelf.count < matchesWithoutParts.count
//            {
//                containsSearchTermRegardlessOfParts = true
//            }
//
//            return matchesNotInSelf
//
//        case .folder: return []
//        }
//    }
//
//    private func contains(line: Int) -> Bool
//    {
//        switch kind
//        {
//        case.folder: return false
//        case.file(let file): return file.lines.count > line
//        case .symbol(let lspDocSymbol): return lspDocSymbol.contains(line: line)
//        }
//    }
}
