import Foundation
import SwiftObserver

// MARK: - Foundation

extension CodeFileAnalytics
{
    init?(url: URL)
    {
        guard let file = CodeFile(url: url) else { return nil }
        
        self.init(file: file)
    }
}

extension CodeFile
{
    init?(url: URL)
    {
        guard let code = try? String(contentsOf: url,
                                     encoding: .utf8) else { return nil }
        
        self.init(path: url.path, content: code)
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
        sort { ($0.file.path < $1.file.path) == ascending }
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
    let path: String
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
