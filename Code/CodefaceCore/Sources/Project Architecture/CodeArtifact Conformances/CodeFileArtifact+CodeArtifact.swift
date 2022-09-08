extension CodeFileArtifact: CodeArtifact
{
    public func sort()
    {
        symbolGraph.sort(by: <)
    }
    
    public var parts: [CodeArtifact]
    {
        symbolGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addDependency(from source: CodeArtifact,
                              to target: CodeArtifact)
    {
        symbolGraph.addEdge(from: source.id, to: target.id)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { lines.count }
    
    public var kindName: String { "File" }
}
