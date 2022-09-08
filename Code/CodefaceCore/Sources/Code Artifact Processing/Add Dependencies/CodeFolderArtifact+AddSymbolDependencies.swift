import SwiftLSP
import SwiftyToolz

extension CodeFolderArtifact
{
    func generateSymbolDependencies()
    {
        let hashMap = CodeFileArtifactHashmap(root: self)
        generateSymbolDependencies(using: hashMap)
    }
    
    private func generateSymbolDependencies(using hashMap: CodeFileArtifactHashmap)
    {
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.generateSymbolDependencies(using: hashMap)
            case .file(let file):
                file.generateSymbolDependencies(using: hashMap)
            }
        }
    }
}

private extension CodeFileArtifact
{
    func generateSymbolDependencies(using hashMap: CodeFileArtifactHashmap)
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

private extension CodeSymbolArtifact
{
    func generateSubsymbolDependenciesRecursively(enclosingFile file: LSPDocumentUri,
                                                  hashMap: CodeFileArtifactHashmap)
    {
        let subsymbolNodes = subsymbolGraph.nodes
        
        for subsymbolNode in subsymbolNodes
        {
            subsymbolNode.value.generateSubsymbolDependenciesRecursively(enclosingFile: file,
                                                                           hashMap: hashMap)
        }
        
        for subsymbolNode in subsymbolNodes
        {
            let ancestorSubsymbols = subsymbolNode.value.getIncoming(enclosingFile: file,
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
        guard let references = symbolDataHash[self]?.lspReferences else
        {
            log(error: "no symbol data exists for this symbol artifact")
            return []
        }
        
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
                dependingSymbol.outOfScopeDependencies += self
            }
        }
        
        return incomingInScope
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
