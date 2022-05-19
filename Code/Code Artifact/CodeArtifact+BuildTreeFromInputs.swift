import SwiftLSP
import SwiftyToolz

extension CodeArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        switch kind
        {
        case .file(let codeFile):
            let lspSymbols = try await server.symbols(for: codeFile)
            
            guard !lspSymbols.isEmpty else
            {
                parts = []
                break
            }
            
            var newParts = [CodeArtifact]()
            
            for lspSymbol in lspSymbols
            {
                do {
                    
                    let references = try await server.request(.references(for: lspSymbol,
                                                                          inFileAtPath: codeFile.path))
                    
                    SwiftyToolz.log("✅ References:\n\(references.description)")
                } catch {
                    SwiftyToolz.log(error)
                }
                
                newParts += CodeArtifact(lspDocSymbol: lspSymbol,
                                         codeFileLines: codeFile.lines)
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
