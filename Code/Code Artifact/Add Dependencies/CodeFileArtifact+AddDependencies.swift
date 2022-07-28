import SwiftLSP

extension CodeFileArtifact
{
    func addDependencies(using server: LSP.ServerCommunicationHandler) async throws
    {
        for symbol in symbols
        {
            try await symbol.addDependencies(enclosingFile: codeFile.path,
                                             using: server)
        }
    }
}
