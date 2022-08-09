import SwiftLSP

extension CodeFileArtifact
{
    func addDependencies(using hashMap: CodeFileArtifactHashmap,
                         _ server: LSP.ServerCommunicationHandler) async throws
    {
        for symbol in symbols
        {
            try await symbol.addSubsymbolDependencies(enclosingFile: codeFile.path,
                                                      hashMap: hashMap,
                                                      server: server)
        }
        
        for symbol in symbols
        {
            let incoming = try await symbol.getIncoming(enclosingFile: codeFile.path,
                                                        hashMap: hashMap,
                                                        server: server)
            
            symbolDependencies.add(incoming)
        }
    }
}
