struct CodeFileAnalytics
{
    init(file: CodeFile, loc: Int)
    {
        self.file = file
        self.linesOfCode = loc
    }
    
    let file: CodeFile
    let linesOfCode: Int
}
