import Foundation
import SwiftObserver

// MARK: - Foundation

extension CodeFileAnalytics
{
    init?(file: URL, folder: URL)
    {
        guard let file = CodeFile(file: file, folder: folder) else { return nil }
        
        self.init(file: file)
    }
}

extension CodeFile
{
    init?(file: URL, folder: URL)
    {
        let filePath = file.absoluteString
        let folderPath = folder.absoluteString
        
        let relativeFilePath = filePath.replacingOccurrences(of: folderPath,
                                                             with: "")
        
        guard filePath != relativeFilePath else
        {
            log(error: "Given file is not in given folder.")
            return nil
        }
        
        guard let code = try? String(contentsOf: file, encoding: .utf8) else
        {
            return nil
        }
        
        self.init(pathInCodeFolder: relativeFilePath, content: code)
    }
}

// MARK: - Model

class Store: Observable
{
    static let shared = Store()
    
    private init() {}
    
    var analytics = [CodeFileAnalytics]()
    {
        didSet { send(.didModifyData) }
    }
    
    var latestUpdate = Event.didNothing
    
    enum Event { case didNothing, didModifyData }
}

extension Array where Element == CodeFileAnalytics
{
    mutating func sortByLinesOfCode(ascending: Bool = false)
    {
        sort { ($0.linesOfCode < $1.linesOfCode) == ascending }
    }
    
    mutating func sortByFilePath(ascending: Bool = true)
    {
        sort { ($0.file.pathInCodeFolder < $1.file.pathInCodeFolder) == ascending }
    }
}

struct CodeFileAnalytics
{
    init(file: CodeFile)
    {
        self.file = file
        self.linesOfCode = file.content.numberOfLines
    }
    
    let file: CodeFile
    let linesOfCode: Int
}

struct CodeFile
{
    let pathInCodeFolder: String
    var content: String
}

// MARK: - Framework Candidates

extension String
{
    var numberOfLines: Int
    {
        var result = 0
        
        enumerateLines { _, _ in result += 1 }
        
        return result
    }
}
