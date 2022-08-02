import CodefaceCore
import SwiftLSP

extension CodeFolderArtifact
{
    func addDependencies(using server: LSP.ServerCommunicationHandler) async throws
    {
        let hashMap = CodeFileArtifactHashmap(root: self)
        try await addDependencies(using: hashMap, server)
    }
    
    private func addDependencies(using hashMap: CodeFileArtifactHashmap,
                                 _ server: LSP.ServerCommunicationHandler) async throws
    {
        for subfolderArtifact in subfolders
        {
            try await subfolderArtifact.addDependencies(using: hashMap, server)
        }
        
        for fileArtifact in files
        {
            try await fileArtifact.addDependencies(using: hashMap, server)
        }
    }
}
