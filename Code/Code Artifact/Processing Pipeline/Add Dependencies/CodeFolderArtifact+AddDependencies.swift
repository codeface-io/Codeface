import SwiftLSP

extension CodeFolderArtifact
{
    func addDependencies(using server: LSP.ServerCommunicationHandler) async throws
    {
        for subfolderArtifact in subfolders
        {
            try await subfolderArtifact.addDependencies(using: server)
        }
        
        for fileArtifact in files
        {
            try await fileArtifact.addDependencies(using: server)
        }
    }
}
