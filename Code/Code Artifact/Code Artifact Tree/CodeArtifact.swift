extension CodeArtifact
{
    var linesOfCode: Int
    {
        metrics.linesOfCode ?? 0
    }
}

protocol CodeArtifact: AnyObject
{
    var metrics: Metrics { get }
    
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    var id: String { get }
}
