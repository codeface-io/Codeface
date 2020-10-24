import Foundation

extension ProjectFolder
{
    convenience init(_ folder: URL) throws
    {
        guard folder.startAccessingSecurityScopedResource() else
        {
            throw "Couldn't access security scoped folder"
        }
        
        defer { folder.stopAccessingSecurityScopedResource() }
        
        let manager = FileManager.default
        
        let unwantedFolders = ["Pods", "Carthage", "Example%20Projects"]
        
        guard let files = manager.files(inDirectory: folder,
                                        extension: "swift",
                                        skipFolders: unwantedFolders) else
        {
            throw "Couldn't get file URLs from folder"
        }
        
        let folderPath = folder.absoluteString
        
        let codeFiles = try files.compactMap
        {
            try CodeFile($0, folderPath: folderPath)
        }
        
        self.init(path: folderPath, codeFiles: codeFiles)
    }
}

extension ProjectFolder.CodeFile
{
    convenience init(_ file: URL, folderPath: String) throws
    {
        let filePath = file.absoluteString
        let relativeFilePath = filePath.replacingOccurrences(of: folderPath, with: "")
        
        guard filePath != relativeFilePath else
        {
            throw "Given file is not in given folder path"
        }
        
        self.init(relativePath: relativeFilePath,
                  content: try String(contentsOf: file, encoding: .utf8))
    }
}
