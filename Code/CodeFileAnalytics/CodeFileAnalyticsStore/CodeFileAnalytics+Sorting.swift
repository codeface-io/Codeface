extension Array where Element == CodeFileAnalytics
{
    mutating func sort(by dimension: CodeFileAnalytics.SortDimension,
                       ascending: Bool)
    {
        switch dimension
        {
        case .linesOfCode: sortByLinesOfCode(ascending: ascending)
        case .filePath: sortByFilePath(ascending: ascending)
        }
    }
    
    private mutating func sortByLinesOfCode(ascending: Bool)
    {
        sort { ($0.linesOfCode < $1.linesOfCode) == ascending }
    }
    
    private mutating func sortByFilePath(ascending: Bool)
    {
        sort { ($0.file.relativePath < $1.file.relativePath) == ascending }
    }
}

extension CodeFileAnalytics
{
    enum SortDimension { case linesOfCode, filePath }
}
