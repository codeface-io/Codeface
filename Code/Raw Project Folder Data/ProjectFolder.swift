class ProjectFolder
{
    init(path: String, codeFiles: [CodeFile])
    {
        self.path = path
        self.codeFiles = codeFiles
    }
    
    let path: String
    let codeFiles: [CodeFile]
    
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
}
