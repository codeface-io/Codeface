import Foundation
import SwiftyToolz

extension CodeFolder
{
    convenience init(_ folder: URL) throws
    {
        let fm = FileManager.default
        
        let unwantedFolders = ["Pods", "Carthage", "Example%20Projects"]
        
        guard let urls = fm.files(inDirectory: folder,
                                  flat: true,
                                  skipFolders: unwantedFolders) else
        {
            throw "Couldn't get file URLs from folder"
        }
        
        var codeFiles = [CodeFile]()
        var subfolders = [CodeFolder]()
        
        for url in urls
        {
            if url.isDirectory
            {
                subfolders.append(try .init(url))
            }
            else if url.pathExtension == "swift"
            {
                codeFiles.append(try .init(url))
            }
        }
        
        self.init(name: folder.lastPathComponent,
                  path: folder.absoluteString,
                  files: codeFiles,
                  subfolders: subfolders)
    }
}

extension CodeFolder.CodeFile
{
    convenience init(_ file: URL) throws
    {
        self.init(name: file.lastPathComponent,
                  path: file.absoluteString,
                  content: try String(contentsOf: file, encoding: .utf8))
    }
}

extension URL
{
    var isDirectory: Bool
    {
        do
        {
            if let result = try resourceValues(forKeys: [.isDirectoryKey]).isDirectory
            {
                return result
            }
        }
        catch { log(error) }
        
        return hasDirectoryPath
    }
}
