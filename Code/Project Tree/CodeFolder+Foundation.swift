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
                let codeFile = try CodeFile(url)
                codeFiles.append(codeFile)
                
                if let projectInspector = projectInspector
                {
                    projectInspector.symbols(for: codeFile).whenFulfilled
                    {
                        do { codeFile.symbols = try $0.get() }
                        catch { log(error) }
                    }
                }
                else
                {
                    log(error: "No \(ProjectInspector.self) is set")
                }
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
