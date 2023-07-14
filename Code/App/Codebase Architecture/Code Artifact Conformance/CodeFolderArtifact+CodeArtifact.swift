extension CodeFolderArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool { false }
}

extension CodeFolderArtifact: CodeArtifact
{
    var parts: [any CodeArtifact]
    {
        partGraph.nodesByID.values.map { $0.value }
    }
    
    var intrinsicSizeInLinesOfCode: Int? { nil }
    var kindName: String { "Folder" }
    var code: String? { nil }
    var lineNumber: Int? { nil }
    
    // MARK: - Hashability
    
    static func == (lhs: CodeFolderArtifact,
                    rhs: CodeFolderArtifact) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
