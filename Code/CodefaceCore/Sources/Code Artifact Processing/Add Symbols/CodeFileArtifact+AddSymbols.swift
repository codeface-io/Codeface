import SwiftLSP
import Foundation
import SwiftyToolz

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
                                                scope: self,
                                                file: codeFile.path,
                                                server: server)
        }
    }
}
