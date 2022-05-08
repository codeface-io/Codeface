import Foundation

class CodeArtifact
{
    convenience init(folder: CodeFolder)
    {
        var childArtifacts = [CodeArtifact]()
        
        childArtifacts += folder.files.map(CodeArtifact.init)
        childArtifacts += folder.subfolders.map(CodeArtifact.init)
        
        self.init(displayName: folder.name,
                  kind: .folder,
                  children: childArtifacts.isEmpty ? nil : childArtifacts)
    }
    
    convenience init(codeFile: CodeFile)
    {
        self.init(displayName: codeFile.name, kind: .file)
    }
    
    init(displayName: String, kind: Kind, children: [CodeArtifact]? = nil)
    {
        self.displayName = displayName
        self.kind = kind
        self.children = children
    }
    
    let id = UUID().uuidString
    let displayName: String
    let kind: Kind
    let children: [CodeArtifact]?
    
    enum Kind { case folder, file, symbol }
}
