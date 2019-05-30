class CodeFileAnalyzer
{
    init(typeRetriever: TypeRetriever)
    {
        self.typeRetriever = typeRetriever
    }
    
    func analyze(_ codeFiles: [CodeFile]) -> [CodeFileAnalytics]
    {
        let generateTypeDependencyGraph = false
        
        let analytics: [CodeFileAnalytics] = codeFiles.map
        {
            let loc = $0.content.numberOfLines
            
            let topLevelTypes: [String] = generateTypeDependencyGraph ? Array(typeRetriever.topLevelTypes(in: $0.content) ?? []) : []
            
            return CodeFileAnalytics(file: $0,
                                     loc: loc,
                                     topLevelTypes: topLevelTypes)
        }
        
        if generateTypeDependencyGraph {
            updateFileDependencies(in: analytics)
        }
        
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
            
            let dependencies: [CodeFileAnalytics] = referencedTypes?.compactMap
            {
                let dependency = fileAnalyticsByDeclaredType[$0]
                
                guard fileAnalytics !== dependency else { return nil }
                
                return dependency
            } ?? []
            
            fileAnalytics.dependencies = Set(dependencies)
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
