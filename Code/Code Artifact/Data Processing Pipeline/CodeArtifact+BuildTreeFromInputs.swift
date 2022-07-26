import SwiftLSP
import Foundation
import SwiftyToolz

extension CodeArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        switch kind
        {
        case .file(let file):
            try await server.notifyDidOpen(file.path, containingText: file.code)
            
            // TODO: consider persisting this as a hashmap to accelerate development via an example data dump
            let lspDocSymbols = try await server.requestSymbols(in: file.path)
            
            parts = [CodeArtifact]()
            
            for lspDocSymbol in lspDocSymbols
            {
                parts += await CodeArtifact(lspDocSymbol: lspDocSymbol,
                                            codeFileLines: file.lines,
                                            scope: self,
                                            file: file.path,
                                            server: server)
            }
            
        case .folder:
            for part in parts
            {
                try await part.addSymbolArtifacts(using: server)
            }
            
        case .symbol:
            break
        }
    }
}

extension CodeArtifact
{
    convenience init(lspDocSymbol: LSPDocumentSymbol,
                     codeFileLines: [String],
                     scope: CodeArtifact?,
                     file: LSPDocumentUri,
                     server: LSP.ServerCommunicationHandler) async
    {
        let references = [LSPLocation]()
//        await server.requestReferencesLoggingError(for: lspDocSymbol,
//                                                                    in: file)
        
        let codeLines = codeFileLines[lspDocSymbol.range.start.line ... lspDocSymbol.range.end.line]
        let code = codeLines.joined(separator: "\n")
        
        let codeSymbol = CodeSymbol(lspDocumentSymbol: lspDocSymbol,
                                    references: references,
                                    code: code)
        
        self.init(kind: .symbol(codeSymbol), scope: scope)
        
        /// create parts recursively
        parts = [CodeArtifact]()
        
        for childSymbol in lspDocSymbol.children
        {
            await parts += CodeArtifact(lspDocSymbol: childSymbol,
                                        codeFileLines: codeFileLines,
                                        scope: self,
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

extension CodeArtifact
{
    convenience init(codeFolder: CodeFolder, scope: CodeArtifact?)
    {
        self.init(kind: .folder(codeFolder.url), scope: scope)
        
        var parts = [CodeArtifact]()
        
        parts += codeFolder.files.map { CodeArtifact(kind: .file($0), scope: self) }
        parts += codeFolder.subfolders.map { CodeArtifact(codeFolder: $0, scope: self) }
        
        self.parts = parts
    }
}
