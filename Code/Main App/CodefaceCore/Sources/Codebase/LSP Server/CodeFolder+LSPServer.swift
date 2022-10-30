import Foundation
import SwiftLSP

extension CodeFolder
{
    func retrieveSymbolReferences(from server: LSP.Server,
                                  codebaseRootFolder: URL) async throws
    {
        try await forEachFileAndItsRelativeFolderPath(folderPath: nil)
        {
            folderPath, file in

            let fileUri = fileURI(forFilePath: folderPath + file.name,
                                  inFolder: codebaseRootFolder)
            
            let absoluteRootFolderPath = codebaseRootFolder.absoluteString
            
            try await server.notifyDidOpen(fileUri,
                                           containingText: file.lines.joined(separator: "\n"))
            
            for symbol in (file.symbols ?? [])
            {
                try await symbol.traverseDepthFirst
                {
                    try await $0.retrieveReferences(in: fileUri,
                                                    codebaseRootPathAbsolute: absoluteRootFolderPath,
                                                    from: server)
                }
            }
        }
    }
    
    func retrieveSymbolData(from server: LSP.Server,
                            codebaseRootFolder: URL) async throws
    {
        try await forEachFileAndItsRelativeFolderPath(folderPath: nil)
        {
            folderPath, file in
            
            let fileUri = fileURI(forFilePath: folderPath + file.name,
                                  inFolder: codebaseRootFolder)
            
            try await server.notifyDidOpen(fileUri,
                                           containingText: file.lines.joined(separator: "\n"))
            
            let retrievedSymbols = try await server.requestSymbols(in: fileUri).compactMap(CodeSymbolData.init)
            file.symbols = retrievedSymbols.isEmpty ? nil : retrievedSymbols
        }
    }
    
    private func fileURI(forFilePath filePath: String, inFolder folder: URL) -> String
    {
        folder.appendingPathComponent(filePath).absoluteString
    }
}

private extension CodeSymbolData
{
    func traverseDepthFirst(_ visit: (CodeSymbolData) async throws -> Void) async rethrows
    {
        for child in (children ?? []) { try await child.traverseDepthFirst(visit) }
        try await visit(self)
    }
}

private extension CodeSymbolData
{
    func retrieveReferences(in enclosingFile: LSPDocumentUri,
                            codebaseRootPathAbsolute: String,
                            from server: LSP.Server) async throws
    {
        guard kind != .Namespace else
        {
            // TODO: sourcekit-lsp detects many wrong dependencies onto namespaces which are Swift extensions ...
            return
        }
        
        // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
        // sourcekit-lsp suggests a few wrong references where there is one of those issues: a) extension of Variable -> Var namespace declaration (plain wrong) b) class Variable -> namespace Var (wrong direction) or c) all range properties are -1 (invalid)
        
        let retrievedLSPReferences = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                                        in: enclosingFile)
        
        if retrievedLSPReferences.isEmpty
        {
            references = nil
        }
        else
        {
            references = retrievedLSPReferences.map
            {
                ReferenceLocation(lspLocation: $0,
                                  codebaseRootPathAbsolute: codebaseRootPathAbsolute)
            }
        }
    }
}

private extension CodeSymbolData.ReferenceLocation
{
    init(lspLocation: LSPLocation, codebaseRootPathAbsolute: String)
    {
        let percentEncodedPath = lspLocation.uri.removing(prefix: codebaseRootPathAbsolute)
        filePathRelativeToRoot = percentEncodedPath.removingPercentEncoding ?? percentEncodedPath
        
        range = lspLocation.range
    }
}

private extension String
{
    func removing(prefix: String) -> String
    {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }
}
