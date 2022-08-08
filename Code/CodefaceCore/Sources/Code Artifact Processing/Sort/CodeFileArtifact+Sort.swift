extension CodeFileArtifact
{
    func sort()
    {
        for symbol in symbols
        {
            symbol.sort()
        }
        
        symbols.sort()
    }
}
