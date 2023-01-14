import SwiftLSP
import SwiftyToolz

extension CodeFolderArtifact
{
    func addCrossScopeDependencies(outOfScopeDependenciesHash: [CodeSymbolArtifact: Set<CodeSymbolArtifact>])
    {
        for partNode in partGraph.nodesByID.values
        {
            switch partNode.value.kind
            {
            case .subfolder(let subfolder):
                subfolder.addCrossScopeDependencies(outOfScopeDependenciesHash: outOfScopeDependenciesHash)
            case .file(let file):
                file.addCrossScopeDependencies(outOfScopeDependenciesHash: outOfScopeDependenciesHash)
            }
        }
    }
}

private extension CodeFileArtifact
{
    func addCrossScopeDependencies(outOfScopeDependenciesHash: [CodeSymbolArtifact: Set<CodeSymbolArtifact>])
    {
        for symbolNode in symbolGraph.nodesByID.values
        {
            symbolNode.value.addCrossScopeDependencies(outOfScopeDependenciesHash: outOfScopeDependenciesHash)
        }
    }
}

private extension CodeSymbolArtifact
{
    func addCrossScopeDependencies(outOfScopeDependenciesHash: [CodeSymbolArtifact: Set<CodeSymbolArtifact>])
    {
        for subsymbolNode in subsymbolGraph.nodesByID.values
        {
            subsymbolNode.value.addCrossScopeDependencies(outOfScopeDependenciesHash: outOfScopeDependenciesHash)
        }
        
        let outOfScopeDependencies = outOfScopeDependenciesHash[self] ?? []
        
        outOfScopeDependencies.forEach(handle(externalDependency:))
    }
    
    func handle(externalDependency targetSymbol: CodeSymbolArtifact)
    {
        // get paths of enclosing scopes
        let sourcePath = getScopePath()
        let targetPath = targetSymbol.getScopePath()
        
        // sanity checks
        assert(self !== targetSymbol, "source and target symbol are the same")
        assert(!sourcePath.isEmpty, "source path is empty")
        assert(!targetPath.isEmpty, "target path is empty")
        assert(sourcePath.last === scope.artifact, "source scope is not last in path")
        assert(targetPath.last === targetSymbol.scope.artifact, "target scope is not last in path")
        assert(sourcePath[0] === targetPath[0], "source path root != target path root")
        
        // find latest (deepest) common scope
        let indexPathOfPotentialCommonScopes = 0 ..< min(sourcePath.count, targetPath.count)
        
        for pathIndex in indexPathOfPotentialCommonScopes.reversed()
        {
            if sourcePath[pathIndex] !== targetPath[pathIndex] { continue }
            
            // found deepest common scope
            let commonScope: any CodeArtifact = sourcePath[pathIndex]
            
            // identify interdependent sibling parts
            let sourcePart: any CodeArtifact =
            pathIndex == sourcePath.count - 1
            ? self
            : sourcePath[pathIndex + 1]
            
            let targetPart: any CodeArtifact =
            pathIndex == targetPath.count - 1
            ? targetSymbol
            : targetPath[pathIndex + 1]
            
            // sanity checks
            assert(sourcePart !== targetPart, "source and target part are the same")
            
            // add dependency between siblings to scope
            return commonScope.addPartDependency(from: sourcePart.id, to: targetPart.id)
        }
    }
}

private extension CodeArtifact
{
    func getScopePath() -> [any CodeArtifact]
    {
        guard let scopeArtifact = scope.artifact else { return [] }
        return scopeArtifact.getScopePath() + scopeArtifact
    }
}
