import Foundation

struct CodeFolder: Equatable
{
    let url: URL
    let files: [CodeFile]
    let subfolders: [CodeFolder]
}
