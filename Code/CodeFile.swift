class CodeFile
{
    init(relativePath: String, content: String)
    {
        self.relativePath = relativePath
        self.content = content
    }
    
    var debugName: String
    {
        return relativePath.components(separatedBy: "/").last ?? "?"
    }
    
    let relativePath: String
    let content: String
}
