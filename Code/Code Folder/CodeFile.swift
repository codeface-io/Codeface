extension CodeFile
{
    var code: String { lines.joined(separator: "\n") }
}

struct CodeFile: Equatable, Codable
{
    let name: String
    let path: String
    let lines: [String]
}
