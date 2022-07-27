extension CodeFolderArtifact: CodeArtifact
{
    func contains(line: Int) -> Bool { false }
}

extension CodeFileArtifact: CodeArtifact
{
    func contains(line: Int) -> Bool
    {
       codeFile.lines.count > line
    }
}

extension CodeSymbolArtifact: CodeArtifact {}

extension CodeArtifact
{
    var linesOfCode: Int
    {
        metrics.linesOfCode ?? 0
    }
}

protocol CodeArtifact: AnyObject
{
    func contains(line: Int) -> Bool
    
    var metrics: Metrics { get }
    
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    var id: String { get }
}
