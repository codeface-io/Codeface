public class Edge<NodeContent: Identifiable & AnyObject & Hashable>
{
    // MARK: - Initialization
    
    init(source: Node<NodeContent>, target: Node<NodeContent>)
    {
        self.source = source
        self.target = target
        
        count = 1
    }
    
    // MARK: - Data
    
    public internal(set) var count: Int
    
    // MARK: - Nodes and Identity
    
    var id: ID { ID(sourceContent: source.content,
                    targetContent: target.content) }
    
    struct ID: Hashable
    {
        init(sourceContent: NodeContent, targetContent: NodeContent)
        {
            self.sourceID = sourceContent.id
            self.targetID = targetContent.id
        }
        
        let sourceID: NodeContent.ID
        let targetID: NodeContent.ID
    }
    
    public let source: Node<NodeContent>
    public let target: Node<NodeContent>
}
