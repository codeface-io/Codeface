import SwiftLSP

extension CodeSymbolArtifact
{
    func addDependencies(enclosingFile file: LSPDocumentUri,
                         using server: LSP.ServerCommunicationHandler) async throws
    {
        for subsymbol in subSymbols
        {
            try await subsymbol.addDependencies(enclosingFile: file,
                                                using: server)
        }
        
        let refs = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                      in: file)
    }
}
