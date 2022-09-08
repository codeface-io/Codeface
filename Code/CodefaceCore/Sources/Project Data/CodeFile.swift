class CodeFile: Codable
{
    init(name: String, path: String, lines: [String])
    {
        self.name = name
        self.path = path
        self.lines = lines
    }
    
    let name: String
    let path: String
    
    var code: String { lines.joined(separator: "\n") }
    let lines: [String]
    
    var symbols = [CodeSymbolData]()
}
