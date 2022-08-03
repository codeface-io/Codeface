extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subSymbols
        {
            subSymbol.sort()
        }
        
        subSymbols.sort
        {
            a, b in
            
            // different components?
            if let componentNumA = a.metrics.componentNumber,
               let componentNumB = b.metrics.componentNumber,
               componentNumA != componentNumB
            {
                return componentNumA < componentNumB
            }
            
            // different topological rank?
            if let ancestorsA  = a.metrics.numberOfAllIncomingDependenciesInScope,
               let ancestorsB  = b.metrics.numberOfAllIncomingDependenciesInScope,
               ancestorsA != ancestorsB
            {
                return ancestorsA < ancestorsB
            }
            
            if a.dependencyDifferenceScope != b.dependencyDifferenceScope
            {
                return a.dependencyDifferenceScope > b.dependencyDifferenceScope
            }
            
            if a.dependencyDifferenceExternal != b.dependencyDifferenceExternal
            {
                return a.dependencyDifferenceExternal > b.dependencyDifferenceExternal
            }
            
            return a.positionInFile < b.positionInFile
        }
    }
}

extension CodeSymbolArtifact
{
    var positionInFile: Int
    {
        range.start.line
    }
}
