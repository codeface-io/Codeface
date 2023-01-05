import Foundation
import SwiftLSP
import SwiftyToolz

extension CodeFolder
{
    func retrieveSymbolsAndReferences(inParentFolderPath parentPath: String? = nil,
                                      from server: LSP.Server,
                                      codebaseRootFolder: URL) async throws -> CodeFolder
    {
        let parentPathWithSlash = parentPath?.appending("/") ?? ""
        let folderPath = parentPathWithSlash + name
        
        var resultingSubFolders = [CodeFolder]()
        
        for subfolder in (subfolders ?? [])
        {
            /// recursive call
            resultingSubFolders += try await subfolder.retrieveSymbolsAndReferences(inParentFolderPath: folderPath,
                                                                                    from: server,
                                                                                    codebaseRootFolder: codebaseRootFolder)
        }
        
        var resultingFiles = [CodeFile]()
        
        for file in (files ?? [])
        {
            let fileUri = CodeFolder.fileURI(forFilePath: folderPath + "/" + file.name,
                                             inRootFolder: codebaseRootFolder)
            
            try await server.notifyDidOpen(fileUri, containingText: file.code)
            
            let retrievedSymbols = try await server.requestSymbols(in: fileUri)
            
            var symbolDataArray = [CodeSymbol]()
            
            for retrievedSymbol in retrievedSymbols
            {
                symbolDataArray += try await CodeSymbol(lspDocumentSymbol: retrievedSymbol,
                                                        enclosingFile: fileUri,
                                                        codebaseRootPathAbsolute: codebaseRootFolder.absoluteString,
                                                        server: server)
            }
            
            /**
             this is where the magic happens: we create a new file instance in which the symbol data is not nil anymore. this quasi copying allows the symbols property to be constant and CodeFile and CodeFolder to be `Sendable`
             */
            resultingFiles += CodeFile(name: file.name,
                                       code: file.code,
                                       symbols: symbolDataArray)
        }
        
        return CodeFolder(name: name,
                          files: resultingFiles,
                          subfolders: resultingSubFolders)
    }
    
    private static func fileURI(forFilePath filePath: String,
                                inRootFolder rootFolder: URL) -> String
    {
        rootFolder.appendingPathComponent(filePath).absoluteString
    }
}

private extension CodeSymbol
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
