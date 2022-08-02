public extension CodeFile
{
    var code: String { lines.joined(separator: "\n") }
}

public struct CodeFile: Equatable, Codable
{
    public let name: String
    public let path: String
    public let lines: [String]
}
