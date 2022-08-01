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
            
            let dependenciesBToA = a.incomingDependencies.filter
            {
                dependentSymbol in dependentSymbol === b
            }.count
            
            let dependenciesAToB = b.incomingDependencies.filter
            {
                dependentSymbol in dependentSymbol === a
            }.count
            
            if dependenciesAToB != dependenciesBToA
            {
                return dependenciesAToB > dependenciesBToA
            }
            
            return a.incomingDependencies.count > b.incomingDependencies.count
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
