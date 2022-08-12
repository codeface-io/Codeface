public extension CodeFolderArtifact
{
    func sort()
    {
        for part in parts
        {
            switch part.kind
            {
            case .subfolder(let folder): folder.sort()
            case .file(let file): file.sort()
            }
        }
        
        // TODO: use OrderedSet and bring back sorting
//        parts.sort { $0.codeArtifact.linesOfCode > $1.codeArtifact.linesOfCode }
    }
}
