struct Graph<NodeContent: Hashable & Identifiable & AnyObject>
{
    /** It is possible that edges lead out of the set of nodes which would fuck up algorithms which are not aware of that – or slow down algorithms which are. Use `reduced(to:)` on `Edges` when you need to make sure the graph's edges are constrained to its nodes.
     
        Average complexity is in O(NumberOfEdges), assuming hashing in `Set` is constant on average.
     */
    
    public init(nodes: Set<Node<NodeContent>> = [],
                edges: Edges<NodeContent> = .empty)
    {
        self.nodes = nodes
        self.edges = edges
    }
    
    public func removing(_ otherEdges: Edges<NodeContent>) -> Graph<NodeContent>
    {
        Graph(nodes: nodes, edges: edges.removing(otherEdges))
    }
    
    public func descandants(of node: Node<NodeContent>) -> [Node<NodeContent>]
    {
        edges.outgoing(from: node).map { $0.target }
    }
    
    public func ancestors(of node: Node<NodeContent>) -> [Node<NodeContent>]
    {
        edges.ingoing(to: node).map { $0.source }
    }
    
    public func ingoingEdges(to node: Node<NodeContent>) -> [Edge<NodeContent>]
    {
        edges.ingoing(to: node)
    }
    
    public func outgoingEdges(from node: Node<NodeContent>) -> [Edge<NodeContent>]
    {
        edges.outgoing(from: node)
    }
    
    public func hasEdge(_ edgeID: Edge<NodeContent>.ID) -> Bool
    {
        edges.contains(edgeID)
    }
    
    public var allEdges: [Edge<NodeContent>] { edges.all }
    
    public var allNodes: Set<Node<NodeContent>> { nodes }
    
    private let nodes: Set<Node<NodeContent>>
    private let edges: Edges<NodeContent>
}
