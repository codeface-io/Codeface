public extension CodeFolderArtifact
{
    func sort()
    {
        for part in parts
        {
            switch part.content.kind
            {
            case .subfolder(let folder): folder.sort()
            case .file(let file): file.sort()
            }
        }
        
        partsByArtifactHash.values.sort { $0.content < $1.content }
    }
}

extension CodeFolderArtifact.PartNode: Comparable
{
    public static func < (lhs: CodeFolderArtifact.PartNode,
                          rhs: CodeFolderArtifact.PartNode) -> Bool { lhs.goesBefore(rhs) }
}
