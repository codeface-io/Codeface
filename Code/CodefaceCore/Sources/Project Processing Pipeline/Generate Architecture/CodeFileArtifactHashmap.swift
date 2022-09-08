import SwiftLSP

class CodeFileArtifactHashmap
{
    init(root: CodeFolderArtifact)
    {
        root.iterateThroughFilesRecursively
        {
            dictionary[$0.uri] = $0
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
        partGraph.values.forEach
        {
            switch $0.kind
            {
            case .subfolder(let subfolder):
                subfolder.iterateThroughFilesRecursively(actOnFile)
            case .file(let file):
                actOnFile(file)
            }
        }
    }
}