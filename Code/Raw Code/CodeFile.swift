extension CodeFile {
    static var dummy: CodeFile {
        .init(name: "dummy file", path: "", content: "")
    }
}

class CodeFile
{
    init(name: String, path: String, content: String)
    {
        self.name = name
        self.path = path
        self.content = content
    }
    
    let name: String
    let path: String
    let content: String
}
