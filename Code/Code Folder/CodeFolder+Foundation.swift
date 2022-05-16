import FoundationToolz
import Foundation
import SwiftyToolz

extension CodeFolder
{
    init?(_ folderURL: URL, codeFileEndings: [String]) throws
    {
        let fileManager = FileManager.default
        
        guard let urls = fileManager.items(inDirectory: folderURL, recursive: false) else
        {
            throw "Couldn't get file URLs from folder"
        }
        
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
                  path: folderURL.absoluteString,
                  files: files,
                  subfolders: subfolders)
    }
}

extension CodeFile
{
    init(_ file: URL) throws
    {
        let content = try String(contentsOf: file, encoding: .utf8)
        
        self.init(name: file.lastPathComponent,
                  path: file.absoluteString,
                  lines: content.components(separatedBy: .newlines))
    }
}
