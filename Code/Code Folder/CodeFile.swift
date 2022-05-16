extension CodeFile
{
    static var dummy: CodeFile
    {
        .init(name: "dummy file", path: "", lines: [])
    }
}

struct CodeFile
{
    init(name: String, path: String, lines: [String])
    {
        self.name = name
        self.path = path
        self.lines = lines
    }
    
    let name: String
    let path: String
    let lines: [String]
}
