public extension CodeFolderArtifact
{
    func sort()
    {
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let folder): folder.sort()
            case .file(let file): file.sort()
            }
        }
        
        partGraph.sortNodes { $0 < $1 }
    }
}

extension CodeFolderArtifact.Part: Comparable
{
    public static func == (lhs: CodeFolderArtifact.Part,
                           rhs: CodeFolderArtifact.Part) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func < (lhs: CodeFolderArtifact.Part,
                          rhs: CodeFolderArtifact.Part) -> Bool { lhs.goesBefore(rhs) }
}
