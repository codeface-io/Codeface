import Foundation
import SwiftLSP
import SwiftyToolz

extension CodeFolder
{
    func retrieveSymbolsAndReferences(at path: RelativeFilePath = .root,
                                      from server: LSP.Server,
                                      codebaseRootFolder: URL) async throws -> CodeFolder
    {
        /// recursive calls
        let resultingSubFolders: [CodeFolder] = try await (subfolders ?? []).asyncMap
        {
            subfolder in
            
            try await subfolder.retrieveSymbolsAndReferences(at: path + subfolder.name,
                                                             from: server,
                                                             codebaseRootFolder: codebaseRootFolder)
        }
        
        let resultingFiles: [CodeFile] = try await (files ?? []).asyncMap
        {
            file in
            
            let fileUri = CodeFolder.fileURI(forFilePath: path + file.name,
                                             inRootFolder: codebaseRootFolder)
            
            try await server.notifyDidOpen(fileUri, containingText: file.code)
            
            let retrievedLSPDocumentSymbols: [LSPDocumentSymbol]? = await
            {
                do
                {
                    let symbols = try await server.requestSymbols(in: fileUri)
                    
                    if let unwrappedSymbols = symbols
                    {
                        log(verbose: "did receive array of \(unwrappedSymbols.count) symbols for file \(file.name)")
                    }
                    else
                    {
                        log(verbose: "did receive no symbol array for file \(file.name)")
                    }
                    
                    return symbols
                }
                catch
                {
                    /**
                     catches error -32007 ("File is not being analyzed") from dart language server and prevents most subsequent such errors
                     
                     the issue is supposedly fixed, but it still occured, and our delay and retry successfully handle it: https://github.com/Dart-Code/Dart-Code/issues/3929
                     */
                    if let lspError = error as? LSP.ErrorResult,
                       lspError.code == -32007
                    {
                        do
                        {
                            let milliSecondsToWait = 500
                            log("↻ Got LSP Error -32007. Will retry requesting symbols from server after \(milliSecondsToWait) ms ...")
                            try await Task.sleep(for: .milliseconds(500))
                            let symbols = try await server.requestSymbols(in: fileUri)
                            log(verbose: "did receive \(symbols?.count ?? 0) symbols (after retry) for file \(file.name)")
                            return symbols
                        }
                        catch
                        {
                            log(error.readable)
                            return []
                        }
                    }
                    
                    // requesting symbols from the server may work for some files but not others, in which case we want to continue with the remaining files, so we log the error and assume zero symbols
                    log(error.readable)
                    return []
                }
            }()
            
            let symbols: [CodeSymbol]? = try await retrievedLSPDocumentSymbols?.asyncMap
            {
                try await CodeSymbol(lspDocumentSymbol: $0,
                                     enclosingFile: fileUri,
                                     codebaseRootPathAbsolute: codebaseRootFolder.absoluteString,
                                     server: server)
            }
            
            /**
             this is where the magic happens: we create a new file instance in which the symbol data is not nil anymore. this quasi copying allows the symbols property to be constant and CodeFile and CodeFolder to be `Sendable`
             */
            return CodeFile(name: file.name,
                            code: file.code,
                            symbols: symbols)
        }
        
        return CodeFolder(name: name,
                          files: resultingFiles,
                          subfolders: resultingSubFolders)
    }
    
    private static func fileURI(forFilePath filePath: RelativeFilePath,
                                inRootFolder rootFolder: URL) -> String
    {
        rootFolder.appendingPathComponent(filePath.string).absoluteString
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
        let resultingChildren: [CodeSymbol] = try await lspDocumentSymbol.children?.asyncMap
        {
            try await CodeSymbol(lspDocumentSymbol: $0,
                                 enclosingFile: enclosingFile,
                                 codebaseRootPathAbsolute: codebaseRootPathAbsolute,
                                 server: server)
        } ?? []
        
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
            // TODO: the language-server-specific workarounds in this file should only be applied if the respective language (or better: language server) is used
            // sourcekit-lsp detects many wrong dependencies onto namespaces which are Swift extensions ...
            return nil
        }
        
        let retrievedReferences = try await server.requestReferences(forSymbolSelectionRange: lspDocumentSymbol.selectionRange,
                                                                     in: enclosingFile)
        
        return retrievedReferences.compactMap
        {
            ReferenceLocation(lspLocation: $0,
                              codebaseRootPathAbsolute: codebaseRootPathAbsolute)
        }
    }
}

private extension CodeSymbol.ReferenceLocation
{
    init?(lspLocation: LSPLocation, codebaseRootPathAbsolute: String)
    {
        guard lspLocation.uri.hasPrefix(codebaseRootPathAbsolute) else
        {
            // sourcekit-lsp suggests weird references from Swift SDKs into our code when our code extends basic types like String. we must ignore those references! so if the referencing file is outside of our codebase, we don't create a reference location
            return nil
        }
        
        let percentEncodedPath = lspLocation.uri.removing(prefix: codebaseRootPathAbsolute)
        filePathRelativeToRoot = percentEncodedPath.removingPercentEncoding ?? percentEncodedPath
        
        range = lspLocation.range
    }
}
