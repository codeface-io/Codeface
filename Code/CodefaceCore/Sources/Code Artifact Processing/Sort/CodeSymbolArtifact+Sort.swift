extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subsymbols
        {
            subSymbol.content.sort()
        }
        
        subsymbols.sort { $0.content < $1.content }
    }
}

extension CodeSymbolArtifact: Comparable
{
    public static func < (lhs: CodeSymbolArtifact,
                          rhs: CodeSymbolArtifact) -> Bool { lhs.goesBefore(rhs) }
}
