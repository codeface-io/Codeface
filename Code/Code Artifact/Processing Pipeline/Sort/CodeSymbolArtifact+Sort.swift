extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subSymbols
        {
            subSymbol.sort()
        }
        
        subSymbols.sort { $0.positionInFile < $1.positionInFile }
    }
}

extension CodeSymbolArtifact
{
    var positionInFile: Int
    {
        range.start.line
    }
}
