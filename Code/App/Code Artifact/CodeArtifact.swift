import SwiftyToolz

protocol SearchableCodeArtifact: CodeArtifact
{
    func contains(fileLine: Int) -> Bool
}

extension CodeArtifact
{
    var linesOfCode: Int { metrics.linesOfCode ?? 0 }
    
    func contains(_ otherArtifact: any CodeArtifact) -> Bool
    {
        if otherArtifact === self { return true }
        guard let otherArtifactScope = otherArtifact.scope else { return false }
        return self === otherArtifactScope ? true : contains(otherArtifactScope)
    }
    
    func traverseDepthFirst(_ visit: (any CodeArtifact) -> Void)
    {
        parts.forEach { $0.traverseDepthFirst(visit) }
        visit(self)
    }
}

public protocol CodeArtifact: AnyObject, Hashable
{
    // analysis
    func sort()
    var metrics: Metrics { get set }
    
    // hierarchy
    var scope: (any CodeArtifact)? { get }

    // TODO: replace parts and addPartDependency by returning the whole graph
    var parts: [any CodeArtifact] { get }
    func addPartDependency(from: ID, to: ID)
    
//    var test: Graph<CodeArtifact> { get }
    
    // basic properties
    var intrinsicSizeInLinesOfCode: Int? { get }
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    // identity
    var id: ID { get }
    typealias ID = String
}
