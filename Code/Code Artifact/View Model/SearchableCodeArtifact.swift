extension CodeFolderArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool { false }
}

extension CodeFileArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool
    {
       codeFile.lines.count > fileLine
    }
}

extension CodeSymbolArtifact: SearchableCodeArtifact
{
    func contains(fileLine: Int) -> Bool
    {
        fileLine >= range.start.line && fileLine <= range.end.line
    }
}

protocol SearchableCodeArtifact: CodeArtifact
{
    func contains(fileLine: Int) -> Bool
}
