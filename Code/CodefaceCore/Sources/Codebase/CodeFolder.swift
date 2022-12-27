extension CodeFolder
{
    func forEachFileAndItsRelativeFolderPath(folderPath: String?,
                                             _ actOnFile: (String, CodeFile) async throws -> Void) async rethrows
    {
        let folderPathWithSlash = folderPath?.appending("/") ?? ""
        
        for subfolder in (subfolders ?? [])
        {
            let subfolderPath = folderPathWithSlash + subfolder.name
            try await subfolder.forEachFileAndItsRelativeFolderPath(folderPath: subfolderPath, actOnFile)
        }
        
        for file in (files ?? [])
        {
            try await actOnFile(folderPathWithSlash, file)
        }
    }
}

public final class CodeFolder: Codable, Sendable
{
    public var looksLikeAPackage: Bool
    {
        if name.lowercased().contains("package") { return true }
        
        return files?.contains { $0.name.lowercased().contains("package") } ?? false
    }
    
    init(name: String,
         files: [CodeFile] = [],
         subfolders: [CodeFolder] = [])
    {
        self.name = name
        self.files = files.isEmpty ? nil : files
        self.subfolders = subfolders.isEmpty ? nil : subfolders
    }
    
    public let name: String
    let files: [CodeFile]?
    let subfolders: [CodeFolder]?
}
