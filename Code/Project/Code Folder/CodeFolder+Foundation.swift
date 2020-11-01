import FoundationToolz
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
        
        var codeFiles = [File]()
        var subfolders = [CodeFolder]()
        
        for url in urls
        {
            if url.isDirectory
            {
                subfolders.append(try CodeFolder(url))
            }
            else if url.pathExtension == "swift"
            {
                codeFiles.append(try File(url))
            }
        }
        
        self.init(name: folder.lastPathComponent,
                  path: folder.absoluteString,
                  files: codeFiles,
                  subfolders: subfolders)
    }
}

extension CodeFolder.File
{
    convenience init(_ file: URL) throws
    {
        self.init(name: file.lastPathComponent,
                  path: file.absoluteString,
                  content: try String(contentsOf: file, encoding: .utf8))
    }
}
