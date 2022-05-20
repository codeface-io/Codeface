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
                do {         
                    let references = try await server.requestReferences(for: lspDocSymbol,
                                                                        in: file.path)
                    
                    if !references.isEmpty
                    {
                        SwiftyToolz.log("✅ References:\n\(references.description)")
                    }
                } catch {
                    SwiftyToolz.log(error)
                }
                
                newParts += CodeArtifact(lspDocSymbol: lspDocSymbol,
                                         codeFileLines: file.lines)
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
    convenience init(lspDocSymbol: LSPDocumentSymbol, codeFileLines: [String])
    {
        let symbolLines = codeFileLines[lspDocSymbol.range.start.line ... lspDocSymbol.range.end.line]
        let symbolCode = symbolLines.joined(separator: "\n")
        
        self.init(kind: .symbol(CodeSymbol(lspDocumentSymbol: lspDocSymbol,
                                           code: symbolCode)),
                  parts: lspDocSymbol.children.map({ CodeArtifact(lspDocSymbol: $0,
                                                                  codeFileLines: codeFileLines) }))
    }
}

extension CodeArtifact
{
    convenience init(codeFolder: CodeFolder)
    {
        var parts = [CodeArtifact]()
        
        parts += codeFolder.files.map { CodeArtifact(kind: .file($0)) }
        parts += codeFolder.subfolders.map { CodeArtifact(codeFolder: $0) }
        
        self.init(kind: .folder(codeFolder),
                  parts: parts)
    }
}
