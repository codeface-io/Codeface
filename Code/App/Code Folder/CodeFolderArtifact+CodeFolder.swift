@BackgroundActor
extension CodeFolderArtifact
{
    convenience init(codeFolder: CodeFolder,
                     scope: (any CodeArtifact)?)
    {
        self.init(name: codeFolder.name, scope: scope)
        
        let partArray = (codeFolder.subfolders ?? []).map
        {
            Part(kind: .subfolder(CodeFolderArtifact(codeFolder: $0, scope: self)))
        }
        +
        (codeFolder.files ?? []).map
        {
            Part(kind: .file(CodeFileArtifact(codeFile: $0, scope: self)))
        }
        
        for part in partArray
        {
            partGraph.insert(part)
        }
    }
}
