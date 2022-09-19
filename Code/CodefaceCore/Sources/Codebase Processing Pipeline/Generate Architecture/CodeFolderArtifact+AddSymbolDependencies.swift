import SwiftLSP
import SwiftNodes
import SwiftyToolz

extension CodeFolderArtifact
{
    func addSymbolDependencies(symbolDataHash: [CodeSymbolArtifact: CodeSymbolData])
    {
        let fileHash = CodeFileArtifactHashmap(root: self)
        
        addSymbolDependencies(using: fileHash,
                              symbolDataHash: symbolDataHash)
    }
    
    private func addSymbolDependencies(using fileHash: CodeFileArtifactHashmap,
                                       symbolDataHash: [CodeSymbolArtifact: CodeSymbolData])
    {
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.addSymbolDependencies(using: fileHash,
                                                symbolDataHash: symbolDataHash)
            case .file(let file):
                file.symbolGraph.addSymbolDependencies(fileHash: fileHash,
                                                       symbolDataHash: symbolDataHash)
            }
        }
    }
}

private extension Graph where NodeValue == CodeSymbolArtifact
{
    func addSymbolDependencies(fileHash: CodeFileArtifactHashmap,
                               symbolDataHash: [CodeSymbolArtifact: CodeSymbolData])
    {
        for symbolNode in nodesByValueID.values
        {
            let symbol = symbolNode.value
            
            symbol.subsymbolGraph.addSymbolDependencies(fileHash: fileHash,
                                                        symbolDataHash: symbolDataHash)
        }
        
        for symbolNode in nodesByValueID.values
        {
            let symbol = symbolNode.value
            
            let ingoing = symbol.getIngoing(fileHash: fileHash,
                                            symbolDataHash: symbolDataHash)
            
            for outOfScopeAncestor in ingoing.outOfScope
            {
                outOfScopeAncestor.outOfScopeDependencies += symbol
            }
            
            for inScopeAncestor in ingoing.inScope
            {
                if let ancestorSymbolNode = node(for: inScopeAncestor)
                {
                    addEdge(from: ancestorSymbolNode, to: symbolNode)
                }
                else
                {
                    log(error: "Tried to add dependency from a symbol for which there is no node in the graph")
                }
            }
        }
    }
}

private extension CodeSymbolArtifact
{
    func getIngoing(fileHash: CodeFileArtifactHashmap,
                    symbolDataHash: [CodeSymbolArtifact: CodeSymbolData]) -> IngoingDependencies
    {
        guard let symbolData = symbolDataHash[self] else
        {
            log(error: "no symbol data exists for this symbol artifact")
            return .empty
        }
        
        guard let references = symbolData.references else { return .empty }
        
        var result = IngoingDependencies()
        
        for referencingLocation in references
        {
            guard let referencingFileArtifact = fileHash[referencingLocation.filePathRelativeToRoot] else
            {
                log(warning: "Couldn't hash file: " + referencingLocation.filePathRelativeToRoot)
                // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
                // sourcekit-lsp suggests weird references from Swift SDKs into our code when our code extends basic types like String. we must ignore those references.
                // Also: srckit-lsp sometimes finds references from OLD files that don't even exist anymore. in that case rebuilding isn't enough. we have to stop the server, delete the package's .build/ folder, rebuild the package and restart the server ... 🤦🏼‍♂️
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
                result.inScope += dependingSymbol
            }
            else
            {
                result.outOfScope += dependingSymbol
            }
        }
        
        return result
    }
    
    struct IngoingDependencies
    {
        static var empty: Self { .init(inScope: [], outOfScope: []) }
        
        // dependency within same scope (between siblings)
        var inScope = Set<CodeSymbolArtifact>()
        
        // across different scopes
        var outOfScope = Set<CodeSymbolArtifact>()
    }
}

private extension CodeFileArtifact
{
    func findSymbolArtifact(containing range: LSPRange) -> CodeSymbolArtifact?
    {
        for symbolNode in symbolGraph.nodesByValueID.values
        {
            if let artifact = symbolNode.value.findSymbolArtifact(containing: range)
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
