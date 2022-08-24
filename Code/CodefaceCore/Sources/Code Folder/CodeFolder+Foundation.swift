import FoundationToolz
import Foundation
import SwiftyToolz

public extension CodeFolder
{
    init?(_ folderURL: URL, codeFileEndings: [String]) throws
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
        
        self.init(url: folderURL,
                  files: files,
                  subfolders: subfolders)
    }
}

public extension CodeFile
{
    init(_ file: URL) throws
    {
        let content = try String(contentsOf: file, encoding: .utf8)
        
        self.init(name: file.lastPathComponent,
                  path: file.absoluteString,
                  lines: content.components(separatedBy: .newlines))
    }
}
