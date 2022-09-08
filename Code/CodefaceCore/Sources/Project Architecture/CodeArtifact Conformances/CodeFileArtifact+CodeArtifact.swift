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
    
    public var intrinsicSizeInLinesOfCode: Int? { codeFile.lines.count }
    
    public var name: String { codeFile.name }
    public var kindName: String { "File" }
    public var code: String? { codeFile.code }
}
