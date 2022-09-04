public struct Edges<Node: GraphNode>
{
    static var empty: Edges<Node> { .init() }
    
    // MARK: - Writing
    
    mutating func remove(_ edge: Edge<Node>)
    {
        hashMap[edge.id] = nil
    }
    
    mutating func add(_ otherEdges: Edges<Node>)
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
        let edgeID = EdgeID(source: source, target: target)
        
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
    
    func reduced(to nodes: Set<Node>) -> Edges<Node>
    {
        var reducedEdges = self
        
        reducedEdges.hashMap.remove
        {
            !nodes.contains($0.source) || !nodes.contains($0.target)
        }
        
        return reducedEdges
    }
    
    func removing(_ otherEdges: Edges<Node>) -> Edges<Node>
    {
        var removed = self
        
        for otherEdge in otherEdges.hashMap.values
        {
            removed.hashMap[otherEdge.id] = nil
        }
        
        return removed
    }
    
    // MARK: - Reading
    
    func contains(_ edgeID: EdgeID) -> Bool
    {
        hashMap[edgeID] != nil
    }
    
    func edge(from source: Node, to target: Node) -> Edge<Node>?
    {
        hashMap[EdgeID(source: source, target: target)]
    }
    
    // TODO: hash by source for performance
    func outgoing(from source: Node) -> [Edge<Node>]
    {
        Array(hashMap.values.filter { $0.source === source })
    }
    
    // TODO: hash by target for performance
    func ingoing(to target: Node) -> [Edge<Node>]
    {
        Array(hashMap.values.filter { $0.target === target })
    }
    
    public var all: [Edge<Node>] { Array(hashMap.values) }
    
    var sources: [Node] { hashMap.values.map { $0.source } }
    var targets: [Node] { hashMap.values.map { $0.target } }
    
    var count: Int { hashMap.count }
    
    // MARK: - Data
    
    private var hashMap = [EdgeID: Edge<Node>]()
    
    typealias EdgeID = Edge<Node>.ID
}

public typealias GraphNode = Hashable & IdentifiableObject
