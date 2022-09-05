public struct Edges<NodeValue: Hashable & Identifiable & AnyObject>
{
    // MARK: - Create
    
    public static var empty: Edges<NodeValue> { .init() }
    
    // MARK: - Write
    
    mutating func remove(_ edge: Edge)
    {
        hashMap[edge.id] = nil
    }
    
    mutating func add(_ otherEdges: Edges<NodeValue>)
    {
        hashMap.merge(otherEdges.hashMap)
        {
            mine, other in
            
            mine.count += other.count
            
            return mine
        }
    }
    
    mutating func addEdge(from source: Node, to target: Node)
    {
        let edgeID = Edge.ID(sourceValue: source.value,
                            targetValue: target.value)
        
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
    
    func reduced(to nodes: Set<Node>) -> Edges<NodeValue>
    {
        var reducedEdges = self
        
        reducedEdges.hashMap.remove
        {
            !nodes.contains($0.source) || !nodes.contains($0.target)
        }
        
        return reducedEdges
    }
    
    func removing(_ otherEdges: Edges<NodeValue>) -> Edges<NodeValue>
    {
        var removed = self
        
        for otherEdge in otherEdges.hashMap.values
        {
            removed.hashMap[otherEdge.id] = nil
        }
        
        return removed
    }
    
    // MARK: - Read
    
    func contains(_ edgeID: Edge.ID) -> Bool
    {
        hashMap[edgeID] != nil
    }
    
    func edge(from source: Node, to target: Node) -> Edge?
    {
        hashMap[Edge.ID(sourceValue: source.value, targetValue: target.value)]
    }
    
    // TODO: hash by source for performance
    func outgoing(from source: Node) -> [Edge]
    {
        Array(hashMap.values.filter { $0.source === source })
    }
    
    // TODO: hash by target for performance
    func ingoing(to target: Node) -> [Edge]
    {
        Array(hashMap.values.filter { $0.target === target })
    }
    
    public var all: [Edge] { Array(hashMap.values) }
    
    var sources: [NodeValue] { hashMap.values.map { $0.source.value } }
    var targets: [NodeValue] { hashMap.values.map { $0.target.value } }
    
    var count: Int { hashMap.count }
    
    // MARK: - Store
    
    private var hashMap = [Edge.ID: Edge]()
    
    public typealias Edge = GraphEdge<NodeValue>
    public typealias Node = GraphNode<NodeValue>
}
