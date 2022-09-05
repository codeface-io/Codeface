import SwiftLSP

extension CodeFileArtifact
{
    func requestReferences(from server: LSP.ServerCommunicationHandler) async throws
    {
        for symbol in symbols
        {
            try await symbol.content.retrieveReferencesRecursively(enclosingFile: codeFile.path,
                                                           server: server)
        }
    }
    
    func generateDependencies(using hashMap: CodeFileArtifactHashmap)
    {
        for symbol in symbols
        {
            symbol.content.generateSubsymbolDependenciesRecursively(enclosingFile: codeFile.path,
                                                            hashMap: hashMap)
        }
        
        for symbolNode in symbols
        {
            let ancestorSymbols = symbolNode.content.getIncoming(enclosingFile: codeFile.path,
                                                                 hashMap: hashMap)
            
            for ancestorSymbol in ancestorSymbols
            {
                if let ancestorSymbolNode = symbols.first(where: { $0.content === ancestorSymbol })
                {
                    symbolDependencies.addEdge(from: ancestorSymbolNode, to: symbolNode)
                }
            }
        }
    }
}
