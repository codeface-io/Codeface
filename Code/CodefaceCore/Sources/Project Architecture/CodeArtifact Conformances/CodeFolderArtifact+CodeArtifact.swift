extension CodeFolderArtifact: CodeArtifact
{
    public func sort()
    {
        partGraph.sort(by: <)
    }
    
    public var parts: [CodeArtifact]
    {
        partGraph.nodesByValueID.values.map { $0.value }
    }
    
    public func addDependency(from sourceArtifact: CodeArtifact,
                              to targetArtifact: CodeArtifact)
    {
        partGraph.addEdge(from: sourceArtifact.id, to: targetArtifact.id)
    }
    
    public var intrinsicSizeInLinesOfCode: Int? { nil }
    public var kindName: String { "Folder" }
    public var code: String? { nil }
}
