import SwiftLSP
import SwiftyToolz

extension CodeArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        switch kind
        {
        case .file(let codeFile):
            let symbols = try await server.symbols(for: codeFile)
            if symbols.isEmpty
            {
                parts = nil
            }
            else
            {
                parts = symbols.map({ CodeArtifact(lspDocSymbol: $0) })
            }
            
        case .folder:
            for part in (parts ?? [])
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
    convenience init(lspDocSymbol: LSPDocumentSymbol)
    {
        self.init(displayName: lspDocSymbol.name,
                  kind: .symbol(lspDocSymbol),
                  parts: lspDocSymbol.children.map({ CodeArtifact(lspDocSymbol: $0) }))
    }
}

extension CodeArtifact
{
    convenience init(codeFolder: CodeFolder)
    {
        var parts = [CodeArtifact]()
        
        parts += codeFolder.files.map { CodeArtifact(codeFile: $0) }
        parts += codeFolder.subfolders.map { CodeArtifact(codeFolder: $0) }
        
        self.init(displayName: codeFolder.name,
                  kind: .folder(codeFolder),
                  parts: parts)
    }
    
    convenience init(codeFile: CodeFile)
    {
        self.init(displayName: codeFile.name, kind: .file(codeFile))
    }
}
