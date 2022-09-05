public class GraphEdge<NodeValue: Identifiable & AnyObject & Hashable>
{
    // MARK: - Initialization
    
    init(source: Node, target: Node)
    {
        self.source = source
        self.target = target
        
        count = 1
    }
    
    // MARK: - Data
    
    public internal(set) var count: Int
    
    // MARK: - Nodes and Identity
    
    var id: ID { ID(sourceValue: source.value,
                    targetValue: target.value) }
    
    public struct ID: Hashable
    {
        init(sourceValue: NodeValue, targetValue: NodeValue)
        {
            self.sourceID = sourceValue.id
            self.targetID = targetValue.id
        }
        
        let sourceID: NodeValue.ID
        let targetID: NodeValue.ID
    }
    
    public let source: Node
    public let target: Node
    
    public typealias Node = GraphNode<NodeValue>
}
