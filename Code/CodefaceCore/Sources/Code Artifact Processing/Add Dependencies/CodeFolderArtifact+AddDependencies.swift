import SwiftLSP

public extension CodeFolderArtifact
{
    func addDependencies(using server: LSP.ServerCommunicationHandler) async throws
    {
        let hashMap = CodeFileArtifactHashmap(root: self)
        try await addDependencies(using: hashMap, server)
    }
    
    private func addDependencies(using hashMap: CodeFileArtifactHashmap,
                                 _ server: LSP.ServerCommunicationHandler) async throws
    {
        for part in parts
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                try await subfolder.addDependencies(using: hashMap, server)
            case .file(let file):
                try await file.addDependencies(using: hashMap, server)
            }
        }
    }
}
