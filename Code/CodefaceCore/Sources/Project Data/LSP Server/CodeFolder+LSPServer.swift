import SwiftLSP

extension CodeFolder
{
    func retrieveSymbolReferences(from server: LSP.ServerCommunicationHandler) async throws
    {
        try await forEachFile
        {
            file in
            
            try await server.notifyDidOpen(file.path, containingText: file.code)
            
            for symbol in file.symbols
            {
                try await symbol.traverseDepthFirst
                {
                    try await $0.retrieveReferences(in: file.path, from: server)
                }
            }
        }
    }
    
    func retrieveSymbolData(from server: LSP.ServerCommunicationHandler) async throws
    {
        try await forEachFile
        {
            file in
            
            try await server.notifyDidOpen(file.path, containingText: file.code)
            
            file.symbols = try await server.requestSymbols(in: file.path)
                .compactMap(CodeSymbolData.init)
        }
    }
    
    func forEachFile(visit: (CodeFile) async throws -> Void) async rethrows
    {
        for subfolder in subfolders
        {
            try await subfolder.forEachFile(visit: visit)
        }
        
        for file in files
        {
            try await visit(file)
        }
    }
}

private extension CodeSymbolData
{
    func traverseDepthFirst(_ visit: (CodeSymbolData) async throws -> Void) async rethrows
    {
        for child in children { try await child.traverseDepthFirst(visit) }
        try await visit(self)
    }
}

private extension CodeSymbolData
{
    func retrieveReferences(in enclosingFile: LSPDocumentUri,
                            from server: LSP.ServerCommunicationHandler) async throws
    {
        guard kind != .Namespace else
        {
            // TODO: sourcekit-lsp detects many wrong dependencies onto namespaces which are Swift extensions ...
            return
        }
        
        // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
        // sourcekit-lsp suggests a few wrong references where there is one of those issues: a) extension of Variable -> Var namespace declaration (plain wrong) b) class Variable -> namespace Var (wrong direction) or c) all range properties are -1 (invalid)
        
        lspReferences = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                           in: enclosingFile)
    }
}
