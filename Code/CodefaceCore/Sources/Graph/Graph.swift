import OrderedCollections

public struct Graph<NodeContent: Hashable & Identifiable & AnyObject>
{
    /** It is possible that edges lead out of the set of nodes which would fuck up algorithms which are not aware of that – or slow down algorithms which are. Use `reduced(to:)` on `Edges` when you need to make sure the graph's edges are constrained to its nodes.
     
        Average complexity is in O(NumberOfEdges), assuming hashing in `Set` is constant on average.
     */
    
    public init(nodes: Set<Node<NodeContent>> = [],
                edges: Edges<NodeContent> = .empty)
    {
        self.nodes = OrderedSet(nodes)
        self.graphEdges = edges
    }
    
    public init(orderedNodes: OrderedSet<Node<NodeContent>>,
                edges: Edges<NodeContent> = .empty)
    {
        self.nodes = orderedNodes
        self.graphEdges = edges
    }
    
    public mutating func addNode(for content: NodeContent)
    {
        nodes.append(Node(content: content))
    }
    
    public mutating func addEdge(from sourceContent: NodeContent,
                                 to targetContent: NodeContent)
    {
        guard let sourceNode = node(for: sourceContent),
              let targetNode = node(for: targetContent)
        else
        {
            print("🛑 Error: Tried to add dependency between nodes that are not in the graph")
            return
        }
        
        addEdge(from: sourceNode, to: targetNode)
    }
    
    public mutating func remove(_ edge: Edge<NodeContent>)
    {
        graphEdges.remove(edge)
    }
    
    public mutating func addEdge(from source: Node<NodeContent>,
                                 to target: Node<NodeContent>)
    {
        graphEdges.addEdge(from: source, to: target)
    }
    
    public func node(for content: NodeContent) -> Node<NodeContent>?
    {
        // TODO: turn ordered set of nodes into ordered dictionary so we can hash the nodes here
        nodes.first { $0.content === content }
    }
    
    public mutating func sortNodes(by areInOrder: (NodeContent, NodeContent) -> Bool)
    {
        nodes.sort { areInOrder($0.content, $1.content) }
    }
    
    public func removing(_ otherEdges: Edges<NodeContent>) -> Graph<NodeContent>
    {
        Graph(orderedNodes: nodes, edges: graphEdges.removing(otherEdges))
    }
    
    public func reduced(to aFewNodes: Set<Node<NodeContent>>) -> Graph<NodeContent>
    {
        Graph(orderedNodes: nodes, edges: graphEdges.reduced(to: aFewNodes))
    }
    
    public func descandants(of node: Node<NodeContent>) -> [Node<NodeContent>]
    {
        graphEdges.outgoing(from: node).map { $0.target }
    }
    
    public func ancestors(of node: Node<NodeContent>) -> [Node<NodeContent>]
    {
        graphEdges.ingoing(to: node).map { $0.source }
    }
    
    public func ingoingEdges(to node: Node<NodeContent>) -> [Edge<NodeContent>]
    {
        graphEdges.ingoing(to: node)
    }
    
    public func outgoingEdges(from node: Node<NodeContent>) -> [Edge<NodeContent>]
    {
        graphEdges.outgoing(from: node)
    }
    
    public func hasEdge(_ edgeID: Edge<NodeContent>.ID) -> Bool
    {
        graphEdges.contains(edgeID)
    }
    
    public var edges: [Edge<NodeContent>] { graphEdges.all }
    
    public var values: [NodeContent] { nodes.elements.map { $0.content } }
    
    public private(set) var nodes: OrderedSet<Node<NodeContent>>
    private var graphEdges: Edges<NodeContent>
}
