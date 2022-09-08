import Foundation

class CodeFolder: Codable
{
    var looksLikeAPackage: Bool
    {
        url.lastPathComponent.lowercased().contains("package")
        || files.contains { $0.name.lowercased().contains("package") }
    }
    
    init(url: URL, files: [CodeFile], subfolders: [CodeFolder]) {
        self.url = url
        self.files = files
        self.subfolders = subfolders
    }
    
    let url: URL
    let files: [CodeFile]
    let subfolders: [CodeFolder]
}
