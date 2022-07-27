import SwiftLSP
import Foundation
import SwiftyToolz

extension CodeFolderArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        for fileArtifact in files
        {
            try await fileArtifact.addSymbolArtifacts(using: server)
        }
        
        for subfolderArtifact in subfolders
        {
            try await subfolderArtifact.addSymbolArtifacts(using: server)
        }
    }
}

extension CodeFileArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        try await server.notifyDidOpen(codeFile.path,
                                       containingText: codeFile.code)
        
        // TODO: consider persisting this as a hashmap to accelerate development via an example data dump
        let lspDocSymbols = try await server.requestSymbols(in: codeFile.path)
        
        symbols = [CodeSymbolArtifact]()
        
        for lspDocSymbol in lspDocSymbols
        {
            symbols += await CodeSymbolArtifact(lspDocSymbol: lspDocSymbol,
                                                codeFileLines: codeFile.lines,
                                                scope: .file(self),
                                                file: codeFile.path,
                                                server: server)
        }
    }
}

extension CodeSymbolArtifact
{
    convenience init(lspDocSymbol: LSPDocumentSymbol,
                     codeFileLines: [String],
                     scope: Scope,
                     file: LSPDocumentUri,
                     server: LSP.ServerCommunicationHandler) async
    {
        let references = [LSPLocation]()
//        await server.requestReferencesLoggingError(for: lspDocSymbol,
//                                                                    in: file)
        
        let codeLines = codeFileLines[lspDocSymbol.range.start.line ... lspDocSymbol.range.end.line]
        let code = codeLines.joined(separator: "\n")
        
        let symbolKind = LSPDocumentSymbol.SymbolKind(rawValue: lspDocSymbol.kind)
        
        let codeSymbol = CodeSymbol(name: lspDocSymbol.name,
                                    kind: symbolKind,
                                    range: lspDocSymbol.range,
                                    references: references,
                                    code: code)
        
        self.init(codeSymbol: codeSymbol, scope: scope)
        
        /// create subsymbols recursively
        subSymbols = [CodeSymbolArtifact]()
        
        for childLSPDocSymbol in lspDocSymbol.children
        {
            await subSymbols += CodeSymbolArtifact(lspDocSymbol: childLSPDocSymbol,
                                                   codeFileLines: codeFileLines,
                                                   scope: .symbol(self),
                                                   file: file,
                                                   server: server)
        }
    }
}

/// to be more failure tolerant (create artifact anyway when references request fails)
private extension LSP.ServerCommunicationHandler
{
    func requestReferencesLoggingError(for symbol: LSPDocumentSymbol,
                                       in document: LSPDocumentUri) async -> [LSPLocation]
    {
        do
        {
            return try await requestReferences(for: symbol, in: document)
        }
        catch
        {
            log(error)
            return []
        }
    }
}
