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
        // FIXME: sorting could be moved to the vie model as it is a matter of graphical representation (?)
//        symbolGraph.sort { $0.goesBefore($1) }
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
