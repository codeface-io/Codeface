public class Edges<Source: Node, Target: Node>
{
    static var empty: Edges<Source, Target> { .init() }
    
    // MARK: - Writing
    
    func add(_ otherEdges: Edges<Source, Target>)
    {
        hashMap.merge(otherEdges.hashMap)
        {
            mine, other in
            
            mine.count += other.count
            
            return mine
        }
    }
    
    func addEdge(from source: Source, to target: Target)
    {
        let edgeID = EdgeType.ID(source: source, target: target)
        
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
    
    // TODO: hash by source for performance
    func outgoing(from source: Source) -> [EdgeType]
    {
        Array(hashMap.values.filter { $0.source === source })
    }
    
    // TODO: hash by target for performance
    func ingoing(to target: Target) -> [EdgeType]
    {
        Array(hashMap.values.filter { $0.target === target })
    }
    
    public var all: [EdgeType] { Array(hashMap.values) }
    
    var sources: [Source] { hashMap.values.map { $0.source } }
    var targets: [Target] { hashMap.values.map { $0.target } }
    
    var count: Int { hashMap.count }
    
    // MARK: - Data
    
    private var hashMap = [EdgeType.ID: EdgeType]()
    
    public typealias EdgeType = Edge<Source, Target>
}
