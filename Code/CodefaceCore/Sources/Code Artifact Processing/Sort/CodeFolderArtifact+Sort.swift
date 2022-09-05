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

extension CodeFolderArtifact.PartNode: Comparable
{
    public static func < (lhs: CodeFolderArtifact.PartNode,
                          rhs: CodeFolderArtifact.PartNode) -> Bool { lhs.goesBefore(rhs) }
}
