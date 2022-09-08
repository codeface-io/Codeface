import SwiftLSP
import SwiftyToolz

extension CodeFolderArtifact
{
    func generateCrossScopeDependencies()
    {
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.generateCrossScopeDependencies()
            case .file(let file):
                file.generateCrossScopeDependencies()
            }
        }
    }
}

private extension CodeFileArtifact
{
    func generateCrossScopeDependencies()
    {
        for symbol in symbolGraph.values
        {
            symbol.generateCrossScopeDependencies(enclosingFile: codeFile.path)
        }
    }
}

private extension CodeSymbolArtifact
{
    func generateCrossScopeDependencies(enclosingFile file: LSPDocumentUri)
    {
        for subsymbolNode in subsymbolGraph.nodes
        {
            subsymbolNode.value.generateCrossScopeDependencies(enclosingFile: file)
        }
        
        for dependency in outOfScopeDependencies
        {
            handleExternalDependence(from: self, to: dependency)
        }
    }
    
    func handleExternalDependence(from sourceSymbol: CodeSymbolArtifact,
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
