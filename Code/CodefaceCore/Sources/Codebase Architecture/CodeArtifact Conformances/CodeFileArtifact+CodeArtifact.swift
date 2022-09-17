extension CodeFileArtifact: CodeArtifact
{
    public func sort()
    {
        symbolGraph.sort(by: <)
    }
    
    public var parts: [any CodeArtifact]
    {
        symbolGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addPartDependency(from sourceID: ID, to targetID: ID)
    {
        symbolGraph.addEdge(from: sourceID, to: targetID)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { lines.count }
    
    public var kindName: String { "File" }
    
    // MARK: - Hashability
    
    public static func == (lhs: CodeFileArtifact,
                           rhs: CodeFileArtifact) -> Bool { lhs === rhs }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
