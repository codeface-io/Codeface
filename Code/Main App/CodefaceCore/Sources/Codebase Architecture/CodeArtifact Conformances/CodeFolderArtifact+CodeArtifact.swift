extension CodeFolderArtifact: CodeArtifact
{
    public func sort()
    {
        partGraph.sort(by: <)
    }
    
    public var parts: [any CodeArtifact]
    {
        partGraph.nodesByID.values.map { $0.value }
    }
    
    public func addPartDependency(from sourceID: ID, to targetID: ID)
    {
        partGraph.addEdge(from: sourceID, to: targetID)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { nil }
    public var kindName: String { "Folder" }
    public var code: String? { nil }
    
    // MARK: - Hashability
    
    public static func == (lhs: CodeFolderArtifact,
                           rhs: CodeFolderArtifact) -> Bool { lhs === rhs }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
