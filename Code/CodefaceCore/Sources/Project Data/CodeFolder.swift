class CodeFolder: Codable
{
    var looksLikeAPackage: Bool
    {
        name.lowercased().contains("package")
            || files.contains { $0.name.lowercased().contains("package") }
    }
    
    init(name: String, files: [CodeFile], subfolders: [CodeFolder])
    {
        self.name = name
        self.files = files
        self.subfolders = subfolders
    }
    
    let name: String
    let files: [CodeFile]
    let subfolders: [CodeFolder]
}
