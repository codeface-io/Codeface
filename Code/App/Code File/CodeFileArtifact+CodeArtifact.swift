extension CodeFileArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool
    {
       lines.count > fileLine
    }
}

extension CodeFileArtifact: CodeArtifact
{
    func sort()
    {
        symbolGraph.sort(by: <)
    }
    
    var parts: [any CodeArtifact]
    {
        symbolGraph.nodesByID.values.map { $0.value }
    }
    
    func addPartDependency(from sourceID: ID, to targetID: ID)
    {
        symbolGraph.addEdge(from: sourceID, to: targetID)
    }
    
    var intrinsicSizeInLinesOfCode: Int? { lines.count }
    
    var kindName: String { "File" }
    
    // MARK: - Hashability
    
    static func == (lhs: CodeFileArtifact,
                           rhs: CodeFileArtifact) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
