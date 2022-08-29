import SwiftLSP

extension CodeFileArtifact
{
    func requestReferences(from server: LSP.ServerCommunicationHandler) async throws
    {
        for symbol in symbols
        {
            try await symbol.retrieveReferencesRecursively(enclosingFile: codeFile.path,
                                                           server: server)
        }
    }
    
    func generateDependencies(using hashMap: CodeFileArtifactHashmap)
    {
        for symbol in symbols
        {
            symbol.generateSubsymbolDependenciesRecursively(enclosingFile: codeFile.path,
                                                            hashMap: hashMap)
        }
        
        for symbol in symbols
        {
            let incoming = symbol.getIncoming(enclosingFile: codeFile.path,
                                              hashMap: hashMap)
            
            symbolDependencies.add(incoming)
        }
    }
}
