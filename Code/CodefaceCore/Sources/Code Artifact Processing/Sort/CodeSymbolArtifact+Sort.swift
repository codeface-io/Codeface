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
            
            if let componentNumA = a.metrics.componentNumber,
               let componentNumB = b.metrics.componentNumber,
               componentNumA != componentNumB
            {
                return componentNumA < componentNumB
            }
            
            let dependenciesBToA = a.incomingDependenciesScope.filter
            {
                dependentSymbol in dependentSymbol === b
            }.count
            
            let dependenciesAToB = b.incomingDependenciesScope.filter
            {
                dependentSymbol in dependentSymbol === a
            }.count
            
            if dependenciesAToB != dependenciesBToA
            {
                return dependenciesAToB > dependenciesBToA
            }
            
            if a.dependencyDifferenceScope != b.dependencyDifferenceScope
            {
                return a.dependencyDifferenceScope < b.dependencyDifferenceScope
            }
            
            if a.dependencyDifferenceExternal != b.dependencyDifferenceExternal
            {
                return a.dependencyDifferenceExternal < b.dependencyDifferenceExternal
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
