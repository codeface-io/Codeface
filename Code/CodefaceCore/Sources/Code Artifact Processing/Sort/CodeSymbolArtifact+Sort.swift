extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subSymbols
        {
            subSymbol.sort()
        }
        
        subSymbols.sort()
    }
}

extension CodeSymbolArtifact: Comparable
{
    public static func < (lhs: CodeSymbolArtifact, rhs: CodeSymbolArtifact) -> Bool
    {
        // different components?
        if let componentNumA = lhs.metrics.componentNumber,
           let componentNumB = rhs.metrics.componentNumber,
           componentNumA != componentNumB
        {
            return componentNumA < componentNumB
        }
        
        // different topological rank?
        if let ancestorsA  = lhs.metrics.numberOfAllIncomingDependenciesInScope,
           let ancestorsB  = rhs.metrics.numberOfAllIncomingDependenciesInScope,
           ancestorsA != ancestorsB
        {
            return ancestorsA < ancestorsB
        }
        
        if lhs.dependencyDifferenceScope != rhs.dependencyDifferenceScope
        {
            return lhs.dependencyDifferenceScope > rhs.dependencyDifferenceScope
        }
        
        if lhs.dependencyDifferenceExternal != rhs.dependencyDifferenceExternal
        {
            return lhs.dependencyDifferenceExternal > rhs.dependencyDifferenceExternal
        }
        
        return lhs.linesOfCode > rhs.linesOfCode
    }
}
