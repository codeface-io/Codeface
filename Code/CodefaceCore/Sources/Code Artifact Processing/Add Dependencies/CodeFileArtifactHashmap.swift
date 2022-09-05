import SwiftLSP

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
        parts.forEach
        {
            switch $0.content.kind
            {
            case .subfolder(let subfolder):
                subfolder.iterateThroughFilesRecursively(actOnFile)
            case .file(let file):
                actOnFile(file)
            }
        }
    }
}
