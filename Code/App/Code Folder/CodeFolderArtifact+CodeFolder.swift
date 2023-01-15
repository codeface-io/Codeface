import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    convenience init(codeFolder: CodeFolder, filePathRelativeToRoot: String)
    {
        let filePathWithSlash = filePathRelativeToRoot.isEmpty ? "" : filePathRelativeToRoot + "/"
        
        self.init(name: codeFolder.name)
        
        let partArray = (codeFolder.subfolders ?? []).map
        {
            Part(kind: .subfolder(.init(codeFolder: $0,
                                        filePathRelativeToRoot: filePathWithSlash + $0.name)))
        }
        +
        (codeFolder.files ?? []).map
        {
            Part(kind: .file(.init(codeFile: $0,
                                   filePathRelativeToRoot: filePathWithSlash + $0.name)))
        }
        
        for part in partArray
        {
            partGraph.insert(part)
        }
    }
}
