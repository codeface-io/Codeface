import SwiftyToolz

extension ArtifactViewModel
{
    // MARK: - Filter
    
    var filteredPartDependencies: [DependencyVM]
    {
        partDependencies.filter
        {
            $0.targetPart.passesSearchFilter && $0.sourcePart.passesSearchFilter
        }
    }
    
    var partsNotPassingFilter: [ArtifactViewModel]
    {
        parts.filter { !$0.passesSearchFilter }
    }
    
    var partsPassingFilter: [ArtifactViewModel]
    {
        parts.filter { $0.passesSearchFilter }
    }
    
    func updateSearchFilter(allPass: Bool)
    {
        guard let containsSearchTermRegardlessOfParts, let partsContainSearchTerm else
        {
            passesSearchFilter = true

            for part in parts
            {
                part.updateSearchFilter(allPass: allPass)
            }

            return
        }

        if allPass || containsSearchTermRegardlessOfParts
        {
            passesSearchFilter = true

            for part in parts
            {
                part.updateSearchFilter(allPass: true)
            }

            return
        }

        passesSearchFilter = partsContainSearchTerm

        for part in parts
        {
            part.updateSearchFilter(allPass: false)
        }
    }
    
    //  MARK: - Results
    
    @discardableResult
    func updateSearchResults(withSearchTerm searchTerm: String) -> Bool
    {
        if searchTerm == ""
        {
            containsSearchTermRegardlessOfParts = nil
            partsContainSearchTerm = nil

            for part in parts
            {
                part.updateSearchResults(withSearchTerm: searchTerm)
            }

            return true
        }

        containsSearchTermRegardlessOfParts = false
        partsContainSearchTerm = false

        for part in parts
        {
            if part.updateSearchResults(withSearchTerm: searchTerm)
            {
                partsContainSearchTerm = true
            }
        }

        if codeArtifact.name.find(searchTerm)
        {
            containsSearchTermRegardlessOfParts = true
        }

        if codeArtifact.kindName.find(searchTerm)
        {
            containsSearchTermRegardlessOfParts = true
        }

        switch kind
        {
        case .folder, .symbol: break

        case .file(let fileArtifact):
            // search in code, then assign these matches recursively to parts
            var allMatches = [Int]()

            for lineIndex in 0 ..< fileArtifact.lines.count
            {
                if fileArtifact.lines[lineIndex].find(searchTerm)
                {
                    allMatches += lineIndex
                }
            }

            assign(searchMatches: allMatches)
        }

        return partsContainSearchTerm ?? false || containsSearchTermRegardlessOfParts ?? false
    }

    @discardableResult
    private func assign(searchMatches: [Int]) -> [Int]
    {
        switch kind
        {
        case .file, .symbol:
            var matchesWithoutParts = searchMatches

            for part in parts
            {
                matchesWithoutParts = part.assign(searchMatches: matchesWithoutParts)
            }

            if matchesWithoutParts.count < searchMatches.count
            {
                partsContainSearchTerm = true
            }

            let matchesNotInSelf = matchesWithoutParts.filter
            {
                !codeArtifact.contains(fileLine: $0)
            }

            if matchesNotInSelf.count < matchesWithoutParts.count
            {
                containsSearchTermRegardlessOfParts = true
            }

            return matchesNotInSelf

        case .folder: return []
        }
    }
}

extension String
{
    func find(_ searchTerm: String) -> Bool
    {
        range(of: searchTerm, options: .caseInsensitive) != nil
    }
}
