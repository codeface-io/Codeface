import SwiftyToolz

class CodeFileAnalytics: Hashable
{
    // MARK: - Initializer
    
    init(file: CodeFile, loc: Int, topLevelTypes: [String])
    {
        self.file = file
        
        self.linesOfCode = loc
        self.topLevelTypes = topLevelTypes
    }
    
    // MARK: - Debug
    
    func printDebug()
    {
        print(file.debugName)
        
        for dependency in dependencies ?? []
        {
            print(" -> " + dependency.file.debugName)
        }
    }
    
    // MARK: - Data
    
    let file: CodeFile
    
    let linesOfCode: Int
    let topLevelTypes: [String]
    var dependencies: Set<CodeFileAnalytics>?
    
    // MARK: - Hashable
    
    var hashValue: HashValue { return SwiftyToolz.hashValue(self) }
    
    static func == (lhs: CodeFileAnalytics, rhs: CodeFileAnalytics) -> Bool
    {
        return lhs === rhs
    }
}
