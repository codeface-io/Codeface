import SwiftyToolz

public class GraphNode<Value: Identifiable>: Identifiable, Hashable
{
    // MARK: - Copying Nodes
    
    /// Required for Making Transformed Copies of Graphs, in which the neighbour caches in the nodes are consistent with that graph's edges
    func copyWithEmptyNeighbourCache() -> Node { .init(value: value) }
    
    // MARK: - Caches for Accessing Neighbours Quickly
    
    public var neighbours: Set<Node> { ancestors + descendants }
    
    public internal(set) var ancestors = Set<Node>()
    public internal(set) var descendants = Set<Node>()
    
    // MARK: - Basics: Value & Identity
    
    init(value: Value) { self.value = value }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs.id == rhs.id }
    
    public typealias Node = GraphNode<Value>
    
    public var id: Value.ID { value.id }
    
    let value: Value
}
