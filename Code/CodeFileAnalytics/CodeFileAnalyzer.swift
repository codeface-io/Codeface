class CodeFileAnalyzer
{
    func analyze(_ codeFiles: [CodeFile]) -> [CodeFileAnalytics]
    {
        codeFiles.map
        {
            CodeFileAnalytics(file: $0, loc: $0.content.numberOfLines)
        }
    }
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
