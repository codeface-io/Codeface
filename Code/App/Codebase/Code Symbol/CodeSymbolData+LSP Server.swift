import FoundationToolz
import SwiftLSP
import SwiftyToolz

extension CodeSymbol
{
    convenience init(lspDocumentSymbol: LSPDocumentSymbol,
                     enclosingFile: LSPDocumentUri,
                     codebaseRootPathAbsolute: String,
                     server: LSP.Server) async throws
    {
        /// depth first recursive calls
        var resultingChildren = [CodeSymbol]()
        
        for child in lspDocumentSymbol.children
        {
            resultingChildren += try await CodeSymbol(lspDocumentSymbol: child,
                                                          enclosingFile: enclosingFile,
                                                          codebaseRootPathAbsolute: codebaseRootPathAbsolute,
                                                          server: server)
        }
        
        /// retrieve references
        let referenceLocations = try await CodeSymbol.retrieveReferences(for: lspDocumentSymbol,
                                                                             in: enclosingFile,
                                                                             codebaseRootPathAbsolute: codebaseRootPathAbsolute,
                                                                             from: server)
        
        /// call designated initializer
        try self.init(lspDocumentySymbol: lspDocumentSymbol,
                      referenceLocations: referenceLocations ?? [],
                      children: resultingChildren)
    }
    
    static func retrieveReferences(for lspDocumentSymbol: LSPDocumentSymbol,
                                   in enclosingFile: LSPDocumentUri,
                                   codebaseRootPathAbsolute: String,
                                   from server: LSP.Server) async throws -> [ReferenceLocation]?
    {
        guard lspDocumentSymbol.decodedKind != .Namespace else
        {
            // TODO: sourcekit-lsp detects many wrong dependencies onto namespaces which are Swift extensions ...
            return nil
        }
        
        // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
        // sourcekit-lsp suggests a few wrong references where there is one of those issues: a) extension of Variable -> Var namespace declaration (plain wrong) b) class Variable -> namespace Var (wrong direction) or c) all range properties are -1 (invalid)
        
        let retrievedReferences = try await server.requestReferences(forSymbolSelectionRange: lspDocumentSymbol.selectionRange,
                                                                     in: enclosingFile)
        
        return retrievedReferences.map
        {
            ReferenceLocation(lspLocation: $0,
                              codebaseRootPathAbsolute: codebaseRootPathAbsolute)
        }
    }
}

private extension CodeSymbol.ReferenceLocation
{
    init(lspLocation: LSPLocation, codebaseRootPathAbsolute: String)
    {
        let percentEncodedPath = lspLocation.uri.removing(prefix: codebaseRootPathAbsolute)
        filePathRelativeToRoot = percentEncodedPath.removingPercentEncoding ?? percentEncodedPath
        
        range = lspLocation.range
    }
}
