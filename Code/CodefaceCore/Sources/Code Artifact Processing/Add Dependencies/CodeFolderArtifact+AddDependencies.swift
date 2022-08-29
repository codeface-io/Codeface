import SwiftLSP

public extension CodeFolderArtifact
{
    func requestReferences(from server: LSP.ServerCommunicationHandler) async throws
    {
        for part in parts
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                try await subfolder.requestReferences(from: server)
            case .file(let file):
                try await file.requestReferences(from: server)
            }
        }
    }
    
    func generateDependencies()
    {
        let hashMap = CodeFileArtifactHashmap(root: self)
        generateDependencies(using: hashMap)
    }
    
    private func generateDependencies(using hashMap: CodeFileArtifactHashmap)
    {
        for part in parts
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.generateDependencies(using: hashMap)
            case .file(let file):
                file.generateDependencies(using: hashMap)
            }
        }
    }
}
