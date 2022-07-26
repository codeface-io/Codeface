import Foundation

struct CodeFolder: Equatable, Codable
{
    let url: URL
    let files: [CodeFile]
    let subfolders: [CodeFolder]
}
