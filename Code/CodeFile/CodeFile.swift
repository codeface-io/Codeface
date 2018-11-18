class CodeFile
{
    init(relativePath: String, content: String)
    {
        self.pathInCodeFolder = relativePath
        self.content = content
    }
    
    let pathInCodeFolder: String
    let content: String
}
