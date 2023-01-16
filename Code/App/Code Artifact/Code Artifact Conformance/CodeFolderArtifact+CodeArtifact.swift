extension CodeFolderArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool { false }
}

extension CodeFolderArtifact: CodeArtifact
{
    func sort()
    {
        // FIXME: sorting could be moved to the view model as it is a matter of graphical representation (?)
//        partGraph.sort { $0.goesBefore($1) }
    }
    
    var parts: [any CodeArtifact]
    {
        partGraph.nodesByID.values.map { $0.value }
    }
    
    var intrinsicSizeInLinesOfCode: Int? { nil }
    var kindName: String { "Folder" }
    var code: String? { nil }
    
    // MARK: - Hashability
    
    static func == (lhs: CodeFolderArtifact,
                    rhs: CodeFolderArtifact) -> Bool { lhs === rhs }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
