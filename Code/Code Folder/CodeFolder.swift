class CodeFolder
{
    init(name: String,
         path: String,
         files: [File],
         subfolders: [CodeFolder])
    {
        self.name = name
        self.path = path
        self.files = files
        self.subfolders = subfolders
    }
    
    let name: String
    let path: String
    let files: [File]
    let subfolders: [CodeFolder]
    
    class File
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
}
