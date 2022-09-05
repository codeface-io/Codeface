import OrderedCollections

public struct Graph<NodeValue: Hashable & Identifiable & AnyObject>
{
    // MARK: - Graph
    
    /**
     It is possible that initial edges lead out of the set of nodes which would fuck up algorithms which are not aware of that – or slow down algorithms which are. Use `reduced(to:)` on `Edges` when you need to make sure the graph's edges are constrained to its nodes.
     */
    public init(nodes: OrderedSet<Node> = [], edges: Set<Edge> = [])
    {
        self.nodes = nodes
        self.hashMap = .init(uniqueKeysWithValues: edges.map { ($0.id, $0) })
    }
    
    public func removing(_ otherEdges: Set<Edge>) -> Graph<NodeValue>
    {
        var removedEdges = hashMap
        
        for otherEdge in otherEdges
        {
            removedEdges[otherEdge.id] = nil
        }
        
        return Graph(nodes: nodes, edges: Set(removedEdges.values))
    }
    
    public func reduced(to aFewNodes: Set<Node>) -> Graph<NodeValue>
    {
        var reducedEdges = hashMap
        
        reducedEdges.remove
        {
            !aFewNodes.contains($0.source) || !aFewNodes.contains($0.target)
        }
        
        return Graph(nodes: nodes, edges: Set(reducedEdges.values))
    }
    
    // MARK: - Edges
    
    public mutating func remove(_ edge: Edge)
    {
        hashMap[edge.id] = nil
    }
    
    public mutating func addEdge(from sourceValue: NodeValue,
                                 to targetValue: NodeValue)
    {
        guard let sourceNode = node(for: sourceValue),
              let targetNode = node(for: targetValue)
        else
        {
            print("🛑 Error: Tried to add dependency between nodes that are not in the graph")
            return
        }
        
        addEdge(from: sourceNode, to: targetNode)
    }
    
    public mutating func addEdge(from source: Node, to target: Node)
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
    
    public func descendants(of node: Node) -> [Node]
    {
        outgoingEdges(from: node).map { $0.target }
    }
    
    public func ancestors(of node: Node) -> [Node]
    {
        ingoingEdges(to: node).map { $0.source }
    }
    
    public func ingoingEdges(to node: Node) -> [Edge]
    {
        // TODO: hash by target for performance
        Array(hashMap.values.filter { $0.target === node })
    }
    
    public func outgoingEdges(from node: Node) -> [Edge]
    {
        // TODO: hash by source for performance
        Array(hashMap.values.filter { $0.source === node })
    }
    
    public func hasEdge(_ edgeID: Edge.ID) -> Bool
    {
        hashMap[edgeID] != nil
    }
    
    public var edges: [Edge] { Array(hashMap.values) }
    
    private var hashMap: [Edge.ID: Edge]
    
    public typealias Edge = GraphEdge<NodeValue>
    
    // MARK: - Nodes
    
    public mutating func sortNodes(by valuesAreInOrder: (NodeValue, NodeValue) -> Bool)
    {
        nodes.sort { valuesAreInOrder($0.value, $1.value) }
    }
    
    public mutating func addNode(for value: NodeValue)
    {
        nodes.append(Node(value: value))
    }
    
    public func node(for value: NodeValue) -> Node?
    {
        // TODO: turn ordered set of nodes into ordered dictionary so we can hash the nodes here
        nodes.first { $0.value === value }
    }
    
    public var values: [NodeValue] { nodes.elements.map { $0.value } }
    
    public private(set) var nodes: OrderedSet<Node>
    
    public typealias Node = GraphNode<NodeValue>
}
