extension CodeFolderArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool { false }
}

extension CodeFolderArtifact: CodeArtifact
{
    func sort()
    {
        partGraph.sort { $0.goesBefore($1) }
    }
    
    var parts: [any CodeArtifact]
    {
        partGraph.nodesByID.values.map { $0.value }
    }
    
    func addPartDependency(from sourceID: ID, to targetID: ID)
    {
        partGraph.addEdge(from: sourceID, to: targetID)
    }
    
    var intrinsicSizeInLinesOfCode: Int? { nil }
    var kindName: String { "Folder" }
    var code: String? { nil }
    
    // MARK: - Hashability
    
    static func == (lhs: CodeFolderArtifact,
                    rhs: CodeFolderArtifact) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
