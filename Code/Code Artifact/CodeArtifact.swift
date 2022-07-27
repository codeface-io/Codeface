extension CodeFolderArtifact: CodeArtifact {}
extension CodeFileArtifact: CodeArtifact {}
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
    var metrics: Metrics { get set }
    
    var passesSearchFilter: Bool { get set }
    var containsSearchTermRegardlessOfParts: Bool? { get set }
    var partsContainSearchTerm: Bool? { get set }
    
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    var id: String { get }
}
