extension CodeFileArtifact
{
    func sort()
    {
        for symbol in symbols
        {
            symbol.content.sort()
        }
        
        symbols.sort { $0.content < $1.content }
    }
}
