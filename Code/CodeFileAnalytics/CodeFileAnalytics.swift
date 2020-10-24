import SwiftyToolz

class CodeFileAnalytics: Hashable
{
    // MARK: - Initializer
    
    init(file: ProjectFolder.CodeFile, loc: Int)
    {
        self.file = file
        self.linesOfCode = loc
    }
    
    // MARK: - Data
    
    let file: ProjectFolder.CodeFile
    let linesOfCode: Int
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(SwiftyToolz.hashValue(self))
    }
    
    static func == (lhs: CodeFileAnalytics, rhs: CodeFileAnalytics) -> Bool
    {
        return lhs === rhs
    }
}
