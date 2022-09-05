import SwiftLSP

extension CodeFileArtifact
{
    func requestReferences(from server: LSP.ServerCommunicationHandler) async throws
    {
        for symbol in symbolGraph.values
        {
            try await symbol.retrieveReferencesRecursively(enclosingFile: codeFile.path,
                                                           server: server)
        }
    }
    
    func generateDependencies(using hashMap: CodeFileArtifactHashmap)
    {
        for symbol in symbolGraph.values
        {
            symbol.generateSubsymbolDependenciesRecursively(enclosingFile: codeFile.path,
                                                            hashMap: hashMap)
        }
        
        for symbolNode in symbolGraph.nodes
        {
            let ancestorSymbols = symbolNode.value.getIncoming(enclosingFile: codeFile.path,
                                                                 hashMap: hashMap)
            
            for ancestorSymbol in ancestorSymbols
            {
                if let ancestorSymbolNode = symbolGraph.node(for: ancestorSymbol)
                {
                    symbolGraph.addEdge(from: ancestorSymbolNode, to: symbolNode)
                }
            }
        }
    }
}
