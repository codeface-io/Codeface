class CodeFileAnalyzer
{
    init(typeRetriever: TypeRetriever)
    {
        self.typeRetriever = typeRetriever
    }
    
    func analyze(_ codeFiles: [CodeFile]) -> [CodeFileAnalytics]
    {
        return codeFiles.map
        {
            let loc = $0.content.numberOfLines
            let topLevelTypes = typeRetriever.topLevelTypes(in: $0.content)
            
            return CodeFileAnalytics(file: $0,
                                     loc: loc,
                                     topLevelTypes: topLevelTypes ?? [])
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
