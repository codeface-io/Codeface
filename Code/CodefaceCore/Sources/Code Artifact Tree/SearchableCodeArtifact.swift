extension CodeFolderArtifact: SearchableCodeArtifact
{
    public func contains(fileLine: Int) -> Bool { false }
}

extension CodeFileArtifact: SearchableCodeArtifact
{
    public func contains(fileLine: Int) -> Bool
    {
       codeFile.lines.count > fileLine
    }
}

extension CodeSymbolArtifact: SearchableCodeArtifact
{
    public func contains(fileLine: Int) -> Bool
    {
        fileLine >= range.start.line && fileLine <= range.end.line
    }
}

public protocol SearchableCodeArtifact: CodeArtifact
{
    func contains(fileLine: Int) -> Bool
}
