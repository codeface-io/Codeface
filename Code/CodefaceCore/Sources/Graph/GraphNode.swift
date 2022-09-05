public class GraphNode<Value: Identifiable & AnyObject & Hashable>: Hashable
{
    init(value: Value)
    {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(value.hashValue)
    }
    
    public static func == (lhs: GraphNode<Value>,
                           rhs: GraphNode<Value>) -> Bool { lhs === rhs }
    
    let value: Value
}
