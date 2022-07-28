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
        let codeLines = codeFileLines[lspDocSymbol.range.start.line ... lspDocSymbol.range.end.line]
        
        self.init(name: lspDocSymbol.name,
                  kind: LSPDocumentSymbol.SymbolKind(rawValue: lspDocSymbol.kind),
                  range: lspDocSymbol.range,
                  selectionRange: lspDocSymbol.selectionRange,
                  code: codeLines.joined(separator: "\n"),
                  scope: scope)
        
        /// create subsymbols recursively
        subSymbols = [CodeSymbolArtifact]()
        
        for childLSPDocSymbol in lspDocSymbol.children
        {
            await subSymbols += CodeSymbolArtifact(lspDocSymbol: childLSPDocSymbol,
                                                   codeFileLines: codeFileLines,
                                                   scope: .symbol(Weak(self)),
                                                   file: file,
                                                   server: server)
        }
    }
}
