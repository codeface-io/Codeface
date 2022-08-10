public class Edges<Node: IdentifiableObject>
{
    static var empty: Edges<Node> { .init() }
    
    // MARK: - Writing
    
    func add(_ otherEdges: Edges<Node>)
    {
        hashMap.merge(otherEdges.hashMap)
        {
            mine, other in
            
            mine.count += other.count
            
            return mine
        }
    }
    
    func addEdge(from source: Node, to target: Node)
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
    
    // MARK: - Reading
    
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
