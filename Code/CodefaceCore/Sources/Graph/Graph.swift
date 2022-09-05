struct Graph<Node: GraphNode>
{
    /** It is possible that edges lead out of the set of nodes which would fuck up algorithms which are not aware of that – or slow down algorithms which are. Use `reduced(to:)` on `Edges` when you need to make sure the graph's edges are constrained to its nodes.
     
        Average complexity is in O(NumberOfEdges), assuming hashing in `Set` is constant on average.
     */
    
    public init(nodes: Set<Node>, edges: Edges<Node>)
    {
        self.nodes = nodes
        self.edges = edges
    }
    
    public func removing(_ otherEdges: Edges<Node>) -> Graph<Node>
    {
        Graph(nodes: nodes, edges: edges.removing(otherEdges))
    }
    
    public func descandants(of node: Node) -> [Node]
    {
        edges.outgoing(from: node).map { $0.target }
    }
    
    public func ancestors(of node: Node) -> [Node]
    {
        edges.ingoing(to: node).map { $0.source }
    }
    
    public func ingoingEdges(to node: Node) -> [Edge<Node>]
    {
        edges.ingoing(to: node)
    }
    
    public func outgoingEdges(from node: Node) -> [Edge<Node>]
    {
        edges.outgoing(from: node)
    }
    
    public func hasEdge(_ edgeID: Edge<Node>.ID) -> Bool
    {
        edges.contains(edgeID)
    }
    
    public var allEdges: [Edge<Node>] { edges.all }
    
    public var allNodes: Set<Node> { nodes }
    
    private let nodes: Set<Node>
    private let edges: Edges<Node>
}
