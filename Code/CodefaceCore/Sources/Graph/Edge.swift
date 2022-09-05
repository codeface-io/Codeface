public class Edge<NodeContent: Identifiable & AnyObject>
{
    // MARK: - Initialization
    
    init(source: NodeContent, target: NodeContent)
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
        init(source: NodeContent, target: NodeContent)
        {
            self.sourceID = source.id
            self.targetID = target.id
        }
        
        let sourceID: NodeContent.ID
        let targetID: NodeContent.ID
    }
    
    public let source: NodeContent
    public let target: NodeContent
}
