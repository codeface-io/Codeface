import SwiftLSP
import Foundation
import SwiftyToolz

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
        
        self.init(name: lspDocSymbol.name,
                  kind: symbolKind,
                  range: lspDocSymbol.range,
                  references: references,
                  code: code,
                  scope: scope)
        
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
