public struct Edges<NodeContent: Hashable & Identifiable & AnyObject>
{
    // MARK: - Create
    
    public static var empty: Edges<NodeContent> { .init() }
    
    // MARK: - Write
    
    mutating func remove(_ edge: Edge<NodeContent>)
    {
        hashMap[edge.id] = nil
    }
    
    mutating func add(_ otherEdges: Edges<NodeContent>)
    {
        hashMap.merge(otherEdges.hashMap)
        {
            mine, other in
            
            mine.count += other.count
            
            return mine
        }
    }
    
    mutating func addEdge(from source: Node<NodeContent>,
                          to target: Node<NodeContent>)
    {
        let edgeID = EdgeID(sourceContent: source.content,
                            targetContent: target.content)
        
        if let edge = hashMap[edgeID]
        {
            edge.count += 1
        }
        else
        {
            hashMap[edgeID] = Edge(source: source, target: target)
        }
    }
    
    // MARK: - Making Transformations
    
    func reduced(to nodes: Set<Node<NodeContent>>) -> Edges<NodeContent>
    {
        var reducedEdges = self
        
        reducedEdges.hashMap.remove
        {
            !nodes.contains($0.source) || !nodes.contains($0.target)
        }
        
        return reducedEdges
    }
    
    func removing(_ otherEdges: Edges<NodeContent>) -> Edges<NodeContent>
    {
        var removed = self
        
        for otherEdge in otherEdges.hashMap.values
        {
            removed.hashMap[otherEdge.id] = nil
        }
        
        return removed
    }
    
    // MARK: - Read
    
    func contains(_ edgeID: EdgeID) -> Bool
    {
        hashMap[edgeID] != nil
    }
    
    func edge(from source: Node<NodeContent>,
              to target: Node<NodeContent>) -> Edge<NodeContent>?
    {
        hashMap[EdgeID(sourceContent: source.content, targetContent: target.content)]
    }
    
    // TODO: hash by source for performance
    func outgoing(from source: Node<NodeContent>) -> [Edge<NodeContent>]
    {
        Array(hashMap.values.filter { $0.source === source })
    }
    
    // TODO: hash by target for performance
    func ingoing(to target: Node<NodeContent>) -> [Edge<NodeContent>]
    {
        Array(hashMap.values.filter { $0.target === target })
    }
    
    public var all: [Edge<NodeContent>] { Array(hashMap.values) }
    
    var sources: [NodeContent] { hashMap.values.map { $0.source.content } }
    var targets: [NodeContent] { hashMap.values.map { $0.target.content } }
    
    var count: Int { hashMap.count }
    
    // MARK: - Store
    
    private var hashMap = [EdgeID: Edge<NodeContent>]()
    
    typealias EdgeID = Edge<NodeContent>.ID
}
