extension CodeSymbolArtifact
{
    func sort()
    {
        for subSymbol in subsymbolGraph.values
        {
            subSymbol.sort()
        }
        
        subsymbolGraph.sortNodes { $0 < $1 }
    }
}

extension CodeSymbolArtifact: Comparable
{
    public static func < (lhs: CodeSymbolArtifact,
                          rhs: CodeSymbolArtifact) -> Bool { lhs.goesBefore(rhs) }
}
