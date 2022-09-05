import SwiftyToolz

public extension CodeArtifact
{
    var linesOfCode: Int
    {
        metrics.linesOfCode ?? 0
    }
    
    func contains(_ otherArtifact: CodeArtifact) -> Bool
    {
        if otherArtifact === self { return true }
        guard let otherArtifactScope = otherArtifact.scope else { return false }
        return self === otherArtifactScope ? true : contains(otherArtifactScope)
    }
}

public protocol CodeArtifact: AnyObject
{
    var metrics: Metrics { get set }
    
    var scope: CodeArtifact? { get }
    func addDependency(from: CodeArtifact, to: CodeArtifact)
    
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    var id: ID { get }
    
    typealias ID = String
}
