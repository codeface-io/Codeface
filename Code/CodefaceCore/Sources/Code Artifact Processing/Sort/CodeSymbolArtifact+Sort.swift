extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subsymbols
        {
            subSymbol.sort()
        }
        
        subsymbols.sort()
    }
}

extension CodeSymbolArtifact: Comparable
{
    public static func < (lhs: CodeSymbolArtifact,
                          rhs: CodeSymbolArtifact) -> Bool { lhs.goesBefore(rhs) }
}
