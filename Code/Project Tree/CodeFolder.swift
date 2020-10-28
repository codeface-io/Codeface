import FoundationToolz

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
        var symbols: [LSPDocumentSymbol] = []
    }
}
