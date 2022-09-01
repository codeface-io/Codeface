import Foundation

public extension CodeFolder
{
    var looksLikeAPackage: Bool
    {
        url.lastPathComponent.lowercased().contains("package")
        || files.contains { $0.name.lowercased().contains("package") }
    }
}

public struct CodeFolder: Equatable, Codable
{
    public let url: URL
    public let files: [CodeFile]
    public let subfolders: [CodeFolder]
}
