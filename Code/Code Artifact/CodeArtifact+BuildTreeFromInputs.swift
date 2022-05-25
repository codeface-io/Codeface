import SwiftLSP
import SwiftyToolz

extension CodeArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        switch kind
        {
        case .file(let file):
            try server.notifyDidOpen(file.path,
                                     containingText: file.lines.joined(separator: "\n"))
            
            let lspDocSymbols = try await server.requestSymbols(in: file.path)
            
            guard !lspDocSymbols.isEmpty else
            {
                parts = []
                break
            }
            
            var newParts = [CodeArtifact]()
            
            for lspDocSymbol in lspDocSymbols
            {   
                newParts += await CodeArtifact(lspDocSymbol: lspDocSymbol,
                                               codeFileLines: file.lines,
                                               scope: self,
                                               file: file.path,
                                               server: server)
            }
            
            parts = newParts
            
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
        let symbolLines = codeFileLines[lspDocSymbol.range.start.line ... lspDocSymbol.range.end.line]
        let symbolCode = symbolLines.joined(separator: "\n")
        
        self.init(kind: .symbol(CodeSymbol(lspDocumentSymbol: lspDocSymbol,
                                           code: symbolCode)),
                  scope: scope)
        
        do
        {
            let references = try await  server.requestReferences(for: lspDocSymbol,
                                                                 in: file)
            
            if !references.isEmpty
            {
                SwiftyToolz.log("✅ References:\n\(references.description)")
            }
        }
        catch
        {
            SwiftyToolz.log(error)
        }
        
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

extension CodeArtifact
{
    convenience init(codeFolder: CodeFolder, scope: CodeArtifact?)
    {
        self.init(kind: .folder(codeFolder), scope: scope)
        
        var parts = [CodeArtifact]()
        
        parts += codeFolder.files.map { CodeArtifact(kind: .file($0), scope: self) }
        parts += codeFolder.subfolders.map { CodeArtifact(codeFolder: $0, scope: self) }
        
        self.parts = parts
    }
}
