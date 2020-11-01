class CodeFileAnalyzer
{
    func analyze(_ codeFolder: CodeFolder) -> [CodeFileAnalytics]
    {
        var result = [CodeFileAnalytics]()
        
        result += codeFolder.files.map
        {
            CodeFileAnalytics(file: $0, loc: $0.content.numberOfLines)
        }
        
        for subfolder in codeFolder.subfolders
        {
            result += analyze(subfolder)
        }
        
        return result
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
