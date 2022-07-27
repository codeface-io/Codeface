extension CodeFileArtifact
{
    func sort()
    {
        for symbol in symbols
        {
            symbol.sort()
        }
        
        symbols.sort { $0.positionInFile < $1.positionInFile }
    }
}
