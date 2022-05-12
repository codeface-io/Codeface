extension CodeFolder {
    static var dummy: CodeFolder {
        .init(name: "dummy folder", path: "", files: [], subfolders: [])
    }
}

class CodeFolder
{
    init(name: String,
         path: String,
         files: [CodeFile],
         subfolders: [CodeFolder])
    {
        self.name = name
        self.path = path
        self.files = files
        self.subfolders = subfolders
    }
    
    let name: String
    let path: String
    let files: [CodeFile]
    let subfolders: [CodeFolder]
}
