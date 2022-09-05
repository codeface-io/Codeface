import SwiftLSP
import SwiftyToolz

extension CodeSymbolArtifact
{
    func retrieveReferencesRecursively(enclosingFile file: LSPDocumentUri,
                                       server: LSP.ServerCommunicationHandler) async throws
    {
        for subsymbol in subsymbolGraph.values
        {
            try await subsymbol.retrieveReferencesRecursively(enclosingFile: file,
                                                              server: server)
        }
        
        try await retrieveReferences(enclosingFile: file, server: server)
    }
    
    private func retrieveReferences(enclosingFile file: LSPDocumentUri,
                                    server: LSP.ServerCommunicationHandler) async throws
    {
        guard kind != .Namespace else
        {
            // TODO: sourcekit-lsp detects many wrong dependencies onto namespaces which are Swift extensions ...
            return
        }
        
        // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
        // sourcekit-lsp suggests a few wrong references where there is one of those issues: a) extension of Variable -> Var namespace declaration (plain wrong) b) class Variable -> namespace Var (wrong direction) or c) all range properties are -1 (invalid)
        
        references = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                        in: file)
        
        //        print("found \(refs.count) referencing lsp locations for symbol artifact")
    }
    
    func generateSubsymbolDependenciesRecursively(enclosingFile file: LSPDocumentUri,
                                                  hashMap: CodeFileArtifactHashmap)
    {
        let subsymbolNodes = subsymbolGraph.nodes
        
        for subsymbolNode in subsymbolNodes
        {
            subsymbolNode.content.generateSubsymbolDependenciesRecursively(enclosingFile: file,
                                                                           hashMap: hashMap)
        }
        
        for subsymbolNode in subsymbolNodes
        {
            let ancestorSubsymbols = subsymbolNode.content.getIncoming(enclosingFile: file,
                                                                       hashMap: hashMap)
            
            for ancestorSubsymbol in ancestorSubsymbols
            {
                if let ancestorSubsymbolNode = subsymbolGraph.node(for: ancestorSubsymbol)
                {
                    subsymbolGraph.addEdge(from: ancestorSubsymbolNode, to: subsymbolNode)
                }
                else
                {
                    log(error: "Tried to add dependency from a symbol for which there is no node in the graph")
                }
            }
        }
    }
    
    func getIncoming(enclosingFile file: LSPDocumentUri,
                     hashMap: CodeFileArtifactHashmap) -> [CodeSymbolArtifact]
    {
        var incomingInScope = [CodeSymbolArtifact]()
        
        for referencingLocation in references
        {
            guard let referencingFileArtifact = hashMap[referencingLocation.uri] else
            {
                // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
                // sourcekit-lsp suggests weird references from Swift SDKs into our code when our code extends basic types like String. we must ignore those references.
                // log(warning: "Could not find file artifact for LSP document URI:\n\(referencingLocation.uri)\nReferenced Symbol \(self.name) of type \(self.kindName) on line \(self.positionInFile) in \(file)")
                continue
            }
            
            guard let dependingSymbol = referencingFileArtifact.findSymbolArtifact(containing: referencingLocation.range) else
            {
                // log(warning: "Could not find referencing symbol artifact\nin file:\(referencingLocation.uri)\nat range: \(referencingLocation.range)\nreferenced symbol \(self.name) of type \(self.kindName) on line \(self.positionInFile) in \(file)")
                continue
            }
            
            guard !dependingSymbol.contains(self) else
            {
                // dependencies of containing symbols onto this one are already implicitly given by that containment (nesting) ... in this context, a symbol also contains itself
                continue
            }
            
            guard !contains(dependingSymbol) else
            {
                // TODO: This can actually happen in code: some symbol depends on its scope (on one of its enclosing symbols (ancestors)). This is a kind of cycle and should be visualized or even pointed out as a red flag ... on the other hand: it can be argued that it's ok and maybe not even worthy of visualization if the symbol depends on its DIRECT scope (parent), for instance a class `Node` may have a property `neighbours` of type `Node` in which case it is more like the `Node` knowing itself rather than a cycle because the property is such an intrinsic and small part of the Node. It's more critical when an actual nested type knows its enclosing type ...
                continue
            }
            
            // TODO: further weirdness (?) of sourcekit-lsp: ist suggests that any usage of a type amounts to a reference to every extension of that type, which is simply not true ... it even suggests that different extensions of the same type are references of each other ... seems like it does not really find references of that specific symbol but just all references of the symbol's name (just string matching, no semantics) 🤦🏼‍♂️
            
            //            if referencingLocation.uri != file
            //            {
            //                print("found dependency 🎉\nfrom \(referencingSymbolArtifact.name) of type \(referencingSymbolArtifact.kindName) on line \(referencingLocation.range.start.line) in \(referencingLocation.uri)\nonto \(name) of type \(kindName) on line \(positionInFile) in \(file)\n")
            //            }
            
            if scope === dependingSymbol.scope
            {
                // dependency within same scope (between siblings)
                incomingInScope += dependingSymbol
            }
            else
            {
                // across different scopes
                handleExternalDependence(from: dependingSymbol, to: self)
            }
        }
        
        return incomingInScope
    }
    
    private func handleExternalDependence(from sourceSymbol: CodeSymbolArtifact,
                                          to targetSymbol: CodeSymbolArtifact)
    {
        // get paths of enclosing scopes
        let sourcePath = sourceSymbol.getScopePath()
        let targetPath = targetSymbol.getScopePath()
        
        // sanity checks
        assert(sourceSymbol !== targetSymbol, "source and target symbol are the same")
        assert(!sourcePath.isEmpty, "source path is empty")
        assert(!targetPath.isEmpty, "target path is empty")
        assert(sourcePath.last === sourceSymbol.scope, "source scope is not last in path")
        assert(targetPath.last === targetSymbol.scope, "target scope is not last in path")
        assert(sourcePath[0] === targetPath[0], "source path root != target path root")
        
        // find latest (deepest) common scope
        let indexPathOfPotentialCommonScopes = 0 ..< min(sourcePath.count,
                                                         targetPath.count)
        
        for pathIndex in indexPathOfPotentialCommonScopes.reversed()
        {
            if sourcePath[pathIndex] !== targetPath[pathIndex] { continue }
            
            // found deepest common scope
            let commonScope = sourcePath[pathIndex]
            
            // identify interdependent sibling parts
            let sourcePart =
            pathIndex == sourcePath.count - 1
            ? sourceSymbol
            : sourcePath[pathIndex + 1]
            
            let targetPart =
            pathIndex == targetPath.count - 1
            ? targetSymbol
            : targetPath[pathIndex + 1]
            
            // sanity checks
            assert(sourcePart !== targetPart, "source and target part are the same")
            
            // add dependency between siblings to scope
            return commonScope.addDependency(from: sourcePart, to: targetPart)
        }
    }
}

private extension CodeArtifact
{
    func getScopePath() -> [CodeArtifact]
    {
        guard let scope = scope else { return [] }
        return scope.getScopePath() + scope
    }
}

private extension CodeFileArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        for symbol in symbolGraph.values
        {
            if let artifact = symbol.findSymbolArtifact(containing: range)
            {
                return artifact
            }
        }
        
        return nil
    }
}

private extension CodeSymbolArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        // depth first!!! we want the deepest symbol that contains the range
        for subsymbol in subsymbolGraph.values
        {
            if let artifact = subsymbol.findSymbolArtifact(containing: range)
            {
                return artifact
            }
        }
        
        return self.range.contains(range) ? self : nil
    }
}
