extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subsymbolGraph.values
        {
            subSymbol.sort()
        }
        
        subsymbolGraph.sort { $0.goesBefore($1) }
    }
}
