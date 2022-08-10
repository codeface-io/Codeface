public class Edge<Source: Node, Target: Node>
{
    // MARK: - Initialization
    
    init(source: Source, target: Target)
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
        init(source: Source, target: Target)
        {
            self.sourceID = source.id
            self.targetID = target.id
        }
        
        let sourceID: Source.ID
        let targetID: Target.ID
    }
    
    public let source: Source
    public let target: Target
}

public typealias Node = IdentifiableObject

public typealias IdentifiableObject = Identifiable & AnyObject
