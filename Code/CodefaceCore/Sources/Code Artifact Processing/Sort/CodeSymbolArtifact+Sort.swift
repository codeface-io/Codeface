extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subsymbols
        {
            subSymbol.sort()
        }
        
        subsymbols.sort()
    }
}

extension CodeSymbolArtifact: Comparable
{
    public static func < (lhs: CodeSymbolArtifact, rhs: CodeSymbolArtifact) -> Bool
    {
        // different components?
        if let componentNumA = lhs.metrics.componentRank,
           let componentNumB = rhs.metrics.componentRank,
           componentNumA != componentNumB
        {
            return componentNumA < componentNumB
        }
        
        // different topological rank?
        if let ancestorsA  = lhs.metrics.topologicalRankInComponent,
           let ancestorsB  = rhs.metrics.topologicalRankInComponent,
           ancestorsA != ancestorsB
        {
            return ancestorsA < ancestorsB
        }
        
        if let dependencyDiffA = lhs.metrics.dependencyDifferenceScope,
           let dependencyDiffB = rhs.metrics.dependencyDifferenceScope,
           dependencyDiffA != dependencyDiffB
        {
            return dependencyDiffA > dependencyDiffB
        }
        
        if lhs.dependencyDifferenceExternal != rhs.dependencyDifferenceExternal
        {
            return lhs.dependencyDifferenceExternal > rhs.dependencyDifferenceExternal
        }
        
        return lhs.linesOfCode > rhs.linesOfCode
    }
}
