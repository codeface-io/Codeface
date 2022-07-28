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
        
        for referencingLocation in refs
        {
            // TODO: get the file artifact via hash map, then identify the symbol with the outgoing dependency ...
            referencingLocation.uri // file containing the symbol with the outgoing dependency
            referencingLocation.range // range (in the file) associated/overlapping with the symbol that depends on self (on this symbol)
            
            
        }
    }
}
