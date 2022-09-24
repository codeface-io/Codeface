import FoundationToolz
import Foundation
import SwiftyToolz

struct SiteFolder
{
    init(path: String = Bundle.main.bundlePath) throws
    {
        guard FileManager.default.fileExists(atPath: path) else
        {
            throw "Folder doesn't exist: " + path
        }
    
        url = URL(fileURLWithPath: path)
        
        log("Found site folder: \(url.lastPathComponent) ✅")
    }
    
    func read(file filePath: String) throws -> String
    {
        try (url + filePath).readText()
    }
    
    func write(text: String, toFile filePath: String) throws
    {
        try (url + filePath).write(text: text)
    }
    
    let url: URL
}
