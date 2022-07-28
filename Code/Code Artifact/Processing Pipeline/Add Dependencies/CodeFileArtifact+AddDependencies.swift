import SwiftLSP

extension CodeFileArtifact
{
    func addDependencies(using hashMap: CodeFileArtifactHashmap,
                         _ server: LSP.ServerCommunicationHandler) async throws
    {
        for symbol in symbols
        {
            try await symbol.addDependencies(enclosingFile: codeFile.path,
                                             hashMap: hashMap,
                                             server: server)
        }
    }
}
