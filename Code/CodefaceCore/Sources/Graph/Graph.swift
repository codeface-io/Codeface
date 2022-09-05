import OrderedCollections

public struct Graph<NodeValue: Hashable & Identifiable & AnyObject>
{
    /** It is possible that initial edges lead out of the set of nodes which would fuck up algorithms which are not aware of that – or slow down algorithms which are. Use `reduced(to:)` on `Edges` when you need to make sure the graph's edges are constrained to its nodes.
     
        Average complexity is in O(NumberOfEdges), assuming hashing in `Set` is constant on average.
     */
    public init(nodes: OrderedSet<Node> = [], edges: Edges<NodeValue> = .empty)
    {
        self.nodes = nodes
        self.graphEdges = edges
    }
    
    public mutating func addNode(for value: NodeValue)
    {
        nodes.append(Node(value: value))
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
    
    public mutating func remove(_ edge: Edge)
    {
        graphEdges.remove(edge)
    }
    
    public mutating func addEdge(from source: Node, to target: Node)
    {
        graphEdges.addEdge(from: source, to: target)
    }
    
    public func node(for value: NodeValue) -> Node?
    {
        // TODO: turn ordered set of nodes into ordered dictionary so we can hash the nodes here
        nodes.first { $0.value === value }
    }
    
    public mutating func sortNodes(by valuesAreInOrder: (NodeValue, NodeValue) -> Bool)
    {
        nodes.sort { valuesAreInOrder($0.value, $1.value) }
    }
    
    public func removing(_ otherEdges: Edges<NodeValue>) -> Graph<NodeValue>
    {
        Graph(nodes: nodes, edges: graphEdges.removing(otherEdges))
    }
    
    public func reduced(to aFewNodes: Set<Node>) -> Graph<NodeValue>
    {
        Graph(nodes: nodes, edges: graphEdges.reduced(to: aFewNodes))
    }
    
    public func descendants(of node: Node) -> [Node]
    {
        graphEdges.outgoing(from: node).map { $0.target }
    }
    
    public func ancestors(of node: Node) -> [Node]
    {
        graphEdges.ingoing(to: node).map { $0.source }
    }
    
    public func ingoingEdges(to node: Node) -> [Edge]
    {
        graphEdges.ingoing(to: node)
    }
    
    public func outgoingEdges(from node: Node) -> [Edge]
    {
        graphEdges.outgoing(from: node)
    }
    
    public func hasEdge(_ edgeID: Edge.ID) -> Bool
    {
        graphEdges.contains(edgeID)
    }
    
    public var edges: [Edge] { graphEdges.all }
    
    public var values: [NodeValue] { nodes.elements.map { $0.value } }
    
    public private(set) var nodes: OrderedSet<Node>
    private var graphEdges: Edges<NodeValue>
    
    public typealias Edge = GraphEdge<NodeValue>
    public typealias Node = GraphNode<NodeValue>
}
