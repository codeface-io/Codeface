import Foundation

public struct CodeFolder: Equatable, Codable
{
    public let url: URL
    public let files: [CodeFile]
    public let subfolders: [CodeFolder]
}
