import FoundationToolz

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
    
    var kindName: String
    {
        [name.fileExtension()?.capitalized, "File"]
            .compactMap({ $0 })
            .joined(separator: " ")
    }
    
    var lineNumber: Int? { nil }
    
    // MARK: - Hashability
    
    static func == (lhs: CodeFileArtifact,
                           rhs: CodeFileArtifact) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
