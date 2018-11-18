class CodeFileAnalyzer
{
    init(typeRetriever: TypeRetriever)
    {
        self.typeRetriever = typeRetriever
    }
    
    func analyze(_ codeFiles: [CodeFile]) -> [CodeFileAnalytics]
    {
        let analytics: [CodeFileAnalytics] = codeFiles.map
        {
            let loc = $0.content.numberOfLines
            let topLevelTypes = typeRetriever.topLevelTypes(in: $0.content)
            
            return CodeFileAnalytics(file: $0,
                                     loc: loc,
                                     topLevelTypes: topLevelTypes ?? [])
        }
        
        updateFileDependencies(in: analytics)
        
        return analytics
    }
    
    private func updateFileDependencies(in analytics: [CodeFileAnalytics])
    {
        var fileAnalyticsByDeclaredType = [String : CodeFileAnalytics]()
        
        for fileAnalytics in analytics
        {
            for declaredType in fileAnalytics.topLevelTypes
            {
                fileAnalyticsByDeclaredType[declaredType] = fileAnalytics
            }
        }
        
        for fileAnalytics in analytics
        {
            let file = fileAnalytics.file
            
            let referencedTypes = typeRetriever.referencedTypes(in: file.content)
            
            fileAnalytics.dependencies = referencedTypes?.compactMap
            {
                fileAnalyticsByDeclaredType[$0]
            } ?? []
        }
    }
    
    var typeRetriever: TypeRetriever
}

extension String
{
    var numberOfLines: Int
    {
        var result = 0
        
        enumerateLines { _, _ in result += 1 }
        
        return result
    }
}
