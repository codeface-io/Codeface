public class Node<NodeContent: Identifiable & AnyObject & Hashable>: Hashable
{
    init(content: NodeContent)
    {
        self.content = content
    }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(content.hashValue) }
    
    public static func == (lhs: Node<NodeContent>,
                           rhs: Node<NodeContent>) -> Bool { lhs === rhs }
    
    let content: NodeContent
}
