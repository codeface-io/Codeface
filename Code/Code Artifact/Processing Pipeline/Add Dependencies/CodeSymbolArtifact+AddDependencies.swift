import SwiftLSP
import SwiftyToolz

extension CodeSymbolArtifact
{
    func addDependencies(enclosingFile file: LSPDocumentUri,
                         hashMap: CodeFileArtifactHashmap,
                         server: LSP.ServerCommunicationHandler) async throws
    {
        for subsymbol in subSymbols
        {
            try await subsymbol.addDependencies(enclosingFile: file,
                                                hashMap: hashMap,
                                                server: server)
        }
        
        let refs = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                      in: file)
        
        for referencingLocation in refs
        {
            guard let referencingFileArtifact = hashMap[referencingLocation.uri] else
            {
                log(warning: "Could not find file artifact for LSP document URI:\n\(referencingLocation.uri)")
                continue
            }
            
            // TODO: identify the symbol with the outgoing dependency (source symbol) ...
            referencingLocation.range // range (in the file) associated/overlapping with the symbol that depends on self (on this symbol)
        }
    }
}
