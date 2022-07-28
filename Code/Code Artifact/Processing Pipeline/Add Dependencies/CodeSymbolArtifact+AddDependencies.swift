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
            
            guard let referencingSymbolArtifact = referencingFileArtifact.findSymbolArtifact(containing: referencingLocation.range) else
            {
                log(warning: "Could not find symbol artifact containing referencing range in file artifact for LSP document URI:\n\(referencingLocation.uri)")
                continue
            }
            
            incomingDependencies += referencingSymbolArtifact
        }
    }
}

extension CodeFileArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        for symbol in symbols
        {
            if let artifact = symbol.findSymbolArtifact(containing: range)
            {
                return artifact
            }
        }
        
        return nil
    }
}

extension CodeSymbolArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        // depth first!!! we want the deepest symbol that contains the range
        for subsymbol in subSymbols
        {
            if let artifact = subsymbol.findSymbolArtifact(containing: range)
            {
                return artifact
            }
        }
        
        return self.range.contains(range) ? self : nil
    }
}

extension LSPRange
{
    func contains(_ otherRange: LSPRange) -> Bool
    {
        if otherRange.start.line < start.line { return false }
        if otherRange.start.line > end.line { return false }
        
        if otherRange.end.line < start.line { return false }
        if otherRange.end.line > end.line { return false }
        
        // TODO: compare character positions as well if start or end lines are equal (4 equalitues to check ...)
        
        return true
    }
}
