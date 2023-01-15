import SwiftyToolz

protocol SearchableCodeArtifact: CodeArtifact
{
    func contains(fileLine: Int) -> Bool
}

extension CodeArtifact
{
    func traverseDepthFirst(_ visit: (any CodeArtifact) -> Void)
    {
        parts.forEach { $0.traverseDepthFirst(visit) }
        visit(self)
    }
}

protocol CodeArtifact: AnyObject, Hashable, Sendable
{
    // analysis
    @BackgroundActor
    func sort()

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
