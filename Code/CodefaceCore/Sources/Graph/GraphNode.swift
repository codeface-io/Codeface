import SwiftyToolz

public class GraphNode<Value: Identifiable>: Identifiable, Hashable
{
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
    
    public internal(set) var value: Value
}
