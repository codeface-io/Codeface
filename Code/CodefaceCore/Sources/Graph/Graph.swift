import OrderedCollections
import SwiftyToolz

public struct Graph<NodeValue: Identifiable>
{
    // MARK: - Create Graphs
    
    public func reduced(to aFewNodes: Set<Node>) -> Graph<NodeValue>
    {
        let reducedEdges = edgesByID.values.filter
        {
            Set([$0.source, $0.target]).isSubset(of: aFewNodes)
        }
        
        return Graph(nodes: aFewNodes, edges: Set(reducedEdges))
    }
    
    public func removing(_ otherEdges: Set<Edge>) -> Graph<NodeValue>
    {
        Graph(orderedNodes: nodesByID, edges: Set(edgesByID.values) - otherEdges)
    }
    
    /**
     It is possible that initial edges lead out of the set of nodes which would fuck up algorithms which are not aware of that – or slow down algorithms which are. Use `reduced(to:)` on `Edges` when you need to make sure the graph's edges are constrained to its nodes.
     */
    public init(nodes: Set<Node>, edges: Set<Edge>)
    {
        self.init(orderedNodes: .init(uniqueKeysWithValues: nodes.map { ($0.id, $0) }),
                  edges: edges)
    }
    
    public init(orderedNodes: OrderedDictionary<Node.ID, Node> = [:], edges: Set<Edge> = [])
    {
        self.nodesByID = orderedNodes
        self.edgesByID = .init(uniqueKeysWithValues: edges.map { ($0.id, $0) })
    }
    
    // MARK: - Edges
    
    public mutating func remove(_ edge: Edge)
    {
        edgesByID[edge.id] = nil
    }
    
    public mutating func addEdge(from sourceValue: NodeValue, to targetValue: NodeValue)
    {
        addEdge(from: sourceValue.id, to: targetValue.id)
    }
    
    public mutating func addEdge(from sourceValueID: NodeValue.ID,
                                 to targetValueID: NodeValue.ID)
    {
        guard let sourceNode = node(for: sourceValueID),
              let targetNode = node(for: targetValueID)
        else
        {
            print("🛑 Error: Tried to add dependency between nodes that are not in the graph")
            return
        }
        
        addEdge(from: sourceNode, to: targetNode)
    }
    
    public mutating func addEdge(from source: Node, to target: Node)
    {
        let edgeID = Edge.ID(sourceValue: source.value, targetValue: target.value)
        
        if let edge = edgesByID[edgeID]
        {
            edge.count += 1
        }
        else
        {
            edgesByID[edgeID] = Edge(from: source, to: target)
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
        Array(edgesByID.values.filter { $0.target === node })
    }
    
    public func outgoingEdges(from node: Node) -> [Edge]
    {
        // TODO: hash by source for performance
        Array(edgesByID.values.filter { $0.source === node })
    }
    
    public func hasEdge(_ edgeID: Edge.ID) -> Bool
    {
        edgesByID[edgeID] != nil
    }
    
    public var edges: [Edge] { Array(edgesByID.values) }
    
    private var edgesByID: [Edge.ID: Edge]
    
    public typealias Edge = GraphEdge<NodeValue>
    
    // MARK: - Nodes
    
    public mutating func sortNodes(by valuesAreInOrder: (NodeValue, NodeValue) -> Bool)
    {
        nodesByID.sort { valuesAreInOrder($0.value.value, $1.value.value) }
    }
    
    public mutating func addNode(for value: NodeValue)
    {
        nodesByID[value.id] = Node(value: value)
    }
    
    public func node(for value: NodeValue) -> Node?
    {
        node(for: value.id)
    }
    
    public func node(for valueID: NodeValue.ID) -> Node?
    {
        nodesByID[valueID]
    }
    
    public var values: [NodeValue] { nodes.map { $0.value } }
    
    public var nodes: [Node] { nodesByID.elements.map { $0.value } }
    
    private var nodesByID = OrderedDictionary<NodeValue.ID, Node>()
    
    public typealias Node = GraphNode<NodeValue>
}
