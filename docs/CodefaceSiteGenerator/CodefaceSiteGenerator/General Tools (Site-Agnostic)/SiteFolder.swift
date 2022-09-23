import Foundation
import SwiftyToolz

struct SiteFolder
{
    init(path: String) throws
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
        let file = url.appendingPathComponent(filePath)
        return try String(contentsOf: file, encoding: .utf8)
    }
    
    func write(html: String, toFile filePath: String) throws
    {
        let file = url.appendingPathComponent(filePath)
        try html.write(to: file, atomically: true, encoding: .utf8)
        log("Did write: \(filePath) ✅")
    }
    
    let url: URL
}
