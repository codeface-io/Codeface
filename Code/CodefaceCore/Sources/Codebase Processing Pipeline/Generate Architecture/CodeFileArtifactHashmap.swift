import SwiftLSP

class CodeFileArtifactHashmap
{
    init(root: CodeFolderArtifact)
    {
        root.forEachFileAndItsRelativeFolderPath(folderPath: nil)
        {
            folderPathWithSlash, file in
            
            filesByRelativeFolderPaths[folderPathWithSlash + file.name] = file
        }
    }
    
    subscript(_ relativeFolderPath: String) -> CodeFileArtifact?
    {
        filesByRelativeFolderPaths[relativeFolderPath]
    }
    
    private var filesByRelativeFolderPaths = [String: CodeFileArtifact]()
}

private extension CodeFolderArtifact
{
    func forEachFileAndItsRelativeFolderPath(folderPath: String?,
                                             _ actOnFile: (String, CodeFileArtifact) -> Void)
    {
        let folderPathWithSlash = folderPath?.appending("/") ?? ""
        
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.forEachFileAndItsRelativeFolderPath(folderPath: folderPathWithSlash + subfolder.name,
                                                              actOnFile)
            case .file(let file):
                actOnFile(folderPathWithSlash, file)
            }
        }
    }
}
