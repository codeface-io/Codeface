extension CodeFileArtifact
{
    func sort()
    {
        for symbol in symbolGraph.values
        {
            symbol.sort()
        }
        
        symbolGraph.sortNodes { $0 < $1 }
    }
}
