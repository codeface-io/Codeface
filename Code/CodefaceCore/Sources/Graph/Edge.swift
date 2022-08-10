public class Edge<Node: IdentifiableObject>
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
    
    var id: ID { ID(source: source, target: target) }
    
    struct ID: Hashable
    {
        init(source: Node, target: Node)
        {
            self.sourceID = source.id
            self.targetID = target.id
        }
        
        let sourceID: Node.ID
        let targetID: Node.ID
    }
    
    public let source: Node
    public let target: Node
}

public typealias IdentifiableObject = Identifiable & AnyObject
