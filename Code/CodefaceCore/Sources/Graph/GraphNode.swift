public class GraphNode<Value: Identifiable>: Identifiable, Hashable
{
    init(value: Value) { self.value = value }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    public static func == (lhs: Node, rhs: Node) -> Bool { lhs.id == rhs.id }
    
    public typealias Node = GraphNode<Value>
    
    public var id: Value.ID { value.id }
    
    let value: Value
}
