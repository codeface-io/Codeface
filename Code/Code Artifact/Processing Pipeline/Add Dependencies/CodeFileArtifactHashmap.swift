import CodefaceCore
import SwiftLSP

@MainActor
class CodeFileArtifactHashmap
{
    init(root: CodeFolderArtifact)
    {
        root.iterateThroughFilesRecursively
        {
            dictionary[$0.codeFile.path] = $0
        }
    }
    
    subscript(_ lspDocURI: LSPDocumentUri) -> CodeFileArtifact?
    {
        dictionary[lspDocURI]
    }
    
    private var dictionary = [LSPDocumentUri: CodeFileArtifact]()
}

extension CodeFolderArtifact
{
    func iterateThroughFilesRecursively(_ actOnFile: (CodeFileArtifact) -> Void)
    {
        subfolders.forEach { $0.iterateThroughFilesRecursively(actOnFile) }
        files.forEach(actOnFile)
    }
}
