import FoundationToolz
import Foundation
import SwiftyToolz

extension CodeFolder
{
    convenience init(_ folder: URL, codeFileEnding: String) throws
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
                subfolders.append(try CodeFolder(url, codeFileEnding: codeFileEnding))
            }
            else if url.pathExtension == codeFileEnding
            {
                codeFiles.append(try CodeFile(url))
            }
        }
        
        self.init(name: folder.lastPathComponent,
                  path: folder.absoluteString,
                  files: codeFiles,
                  subfolders: subfolders)
    }
}

extension CodeFile
{
    convenience init(_ file: URL) throws
    {
        self.init(name: file.lastPathComponent,
                  path: file.absoluteString,
                  content: try String(contentsOf: file, encoding: .utf8))
    }
}
