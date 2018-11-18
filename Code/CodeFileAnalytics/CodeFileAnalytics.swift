struct CodeFileAnalytics
{
    init(file: CodeFile, loc: Int, topLevelTypes: [String])
    {
        self.file = file
        
        self.linesOfCode = loc
        self.topLevelTypes = topLevelTypes
    }
    
    let file: CodeFile
    
    let linesOfCode: Int
    let topLevelTypes: [String]
}
