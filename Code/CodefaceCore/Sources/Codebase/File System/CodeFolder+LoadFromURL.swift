import FoundationToolz
import Foundation
import SwiftyToolz

public extension CodeFolder
{
    convenience init?(_ folderURL: URL, codeFileEndings: [String]) throws
    {
        let fileManager = FileManager.default
        
        let urls = fileManager.items(inDirectory: folderURL, recursive: false)
        
        var files = [CodeFile]()
        var subfolders = [CodeFolder]()
        
        for url in urls
        {
            if url.isDirectory
            {
                if let subfolder = try CodeFolder(url, codeFileEndings: codeFileEndings)
                {
                    subfolders += subfolder
                }
            }
            else if codeFileEndings.contains(url.pathExtension)
            {
                files += try CodeFile(url)
            }
        }
        
        if files.count + subfolders.count == 0 { return nil }
        
        self.init(name: folderURL.lastPathComponent,
                  files: files,
                  subfolders: subfolders)
    }
    
    func printSize()
    {
        if let encoded = encode()
        {
            log(name + " size: \(Double(encoded.count) / 1000_000) MB")
        }
    }
}

private extension CodeFile
{
    convenience init(_ file: URL) throws
    {
        self.init(name: file.lastPathComponent,
                  code: try String(contentsOf: file, encoding: .utf8))
    }
}
