extension CodeFileArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool
    {
       lines.count > fileLine
    }
}

extension CodeFileArtifact: CodeArtifact
{
    var parts: [any CodeArtifact]
    {
        symbolGraph.nodesByID.values.map { $0.value }
    }
    
    var intrinsicSizeInLinesOfCode: Int? { lines.count }
    
    var kindName: String { "File" }
    
    // MARK: - Hashability
    
    static func == (lhs: CodeFileArtifact,
                           rhs: CodeFileArtifact) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
