import FoundationToolz
import Foundation
import SwiftyToolz

extension CodeFolder
{
    init?(_ folderURL: URL, codeFileEndings: [String]) throws
    {
        let fm = FileManager.default
        
        guard let urls = fm.files(inDirectory: folderURL,
                                  flat: true,
                                  skipFolders: []) else
        {
            throw "Couldn't get file URLs from folder"
        }
        
        var codeFiles = [CodeFile]()
        var subfolders = [CodeFolder]()
        
        var hasAtLeastOneCodeFile = false
        
        for url in urls
        {
            if url.isDirectory
            {
                if let folder = try CodeFolder(url, codeFileEndings: codeFileEndings)
                {
                    subfolders.append(folder)
                    hasAtLeastOneCodeFile = true
                }
            }
            else if codeFileEndings.contains(url.pathExtension)
            {
                codeFiles.append(try CodeFile(url))
                hasAtLeastOneCodeFile = true
            }
        }
        
        if !hasAtLeastOneCodeFile { return nil }
        
        self.init(name: folderURL.lastPathComponent,
                  path: folderURL.absoluteString,
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
