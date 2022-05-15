import FoundationToolz
import Foundation
import SwiftyToolz

extension CodeFolder
{
    init(_ folder: URL, codeFileEndings: [String]) throws
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
                subfolders.append(try CodeFolder(url,
                                                 codeFileEndings: codeFileEndings))
            }
            else if codeFileEndings.contains(url.pathExtension)
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
    init(_ file: URL) throws
    {
        self.init(name: file.lastPathComponent,
                  path: file.absoluteString,
                  content: try String(contentsOf: file, encoding: .utf8))
    }
}
