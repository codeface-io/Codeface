extension CodeFileArtifact
{
    func sort()
    {
        for symbol in symbolGraph.values
        {
            symbol.sort()
        }
        
        symbolGraph.sort { $0.goesBefore($1) }
    }
}
