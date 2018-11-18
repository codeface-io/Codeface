class CodeFile
{
    init(relativePath: String, content: String)
    {
        self.relativePath = relativePath
        self.content = content
    }
    
    let relativePath: String
    let content: String
}
