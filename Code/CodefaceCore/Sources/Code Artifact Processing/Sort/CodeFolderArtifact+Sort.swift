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
        
        partGraph.sort { $0.goesBefore($1) }
    }
}
