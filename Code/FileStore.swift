import Foundation
import SwiftObserver

extension CodeFile
{
    init?(url: URL)
    {
        guard let code = try? String(contentsOf: url,
                                     encoding: .utf8) else { return nil }
        
        self.init(path: url.absoluteString, content: code)
    }
}

class CodeFileStore
{
    static let shared = CodeFileStore()
    
    private init() {}
    
    var files = [CodeFile]()
    {
        didSet
        {
            log("did set \(files.count) code files")
        }
    }
}

struct CodeFile
{
    let path: String
    var content: String
}
