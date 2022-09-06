import OrderedCollections
import SwiftyToolz

public struct Graph<NodeValue: Identifiable>
{
    // MARK: - Copy Subsets
    
    public func copyReducing(to reducedNodes: Set<Node>) -> Graph<NodeValue>
    {
        let reducedNodesByIDKeysAndValues = reducedNodes.map { ($0.id, $0) }
        let reducedNodesByID = NodesHash(uniqueKeysWithValues: reducedNodesByIDKeysAndValues)
        
        return copy(includedNodes: reducedNodesByID)
    }
    
    public func copyRemoving(_ otherEdges: Set<Edge>) -> Graph<NodeValue>
    {
        copy(includedEdges: Set(edgesByID.values) - otherEdges)
    }
    
    public func copy(includedNodes: NodesHash? = nil,
                     includedEdges: Set<Edge>? = nil) -> Graph<NodeValue>
    {
        let nodesByIDOriginal = includedNodes ?? nodesByID
        let nodesByIDKeysValuesCopy = nodesByIDOriginal.map { ($0.key, Node(value: $0.value.value)) }
        let nodesByIDCopy = NodesHash(uniqueKeysWithValues: nodesByIDKeysValuesCopy)
        
        var graphCopy = Graph(orderedNodes: nodesByIDCopy)
        
        for originalEdge in includedEdges ?? Set(edgesByID.values)
        {
            graphCopy.addEdge(from: originalEdge.source.value, to: originalEdge.target.value)
        }
        
        return graphCopy
    }
    
    // MARK: - Initialize
    
    public init(nodes: Set<Node>)
    {
        self.init(orderedNodes: .init(uniqueKeysWithValues: nodes.map { ($0.id, $0) }))
    }
    
    public init(orderedNodes: NodesHash = [:])
    {
        self.nodesByID = orderedNodes
    }
    
    // MARK: - Edges
    
    public mutating func remove(_ edge: Edge)
    {
        // remove from node caches
        edge.source.descendants -= edge.target
        edge.target.ancestors -= edge.source
        
        // remove edge itself
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
              let targetNode = node(for: targetValueID) else { return }
        
        addEdge(from: sourceNode, to: targetNode)
    }
    
    public mutating func addEdge(from source: Node, to target: Node)
    {
        let edgeID = Edge.ID(sourceValue: source.value, targetValue: target.value)
        
        if let edge = edgesByID[edgeID]
        {
            edge.count += 1
            
            // TODO: maintain count in edge caches in nodes as well, for algorithms that take edge weight into account when traversing the graph, like dijkstra shortest path ...
        }
        else
        {
            edgesByID[edgeID] = Edge(from: source, to: target)
        }
    }
    
    public func edge(from source: Node, to target: Node) -> Edge?
    {
        edgesByID[.init(sourceValue: source.value, targetValue: target.value)]
    }
    
    public var edges: [Edge] { Array(edgesByID.values) }
    
    private var edgesByID = [Edge.ID: Edge]()
    
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
    
    public var sources: [Node] { nodes.filter { $0.ancestors.count == 0 } }
    public var sinks: [Node] { nodes.filter { $0.descendants.count == 0 } }
    
    public var nodes: [Node] { nodesByID.elements.map { $0.value } }
    
    private var nodesByID = NodesHash()
    
    public typealias NodesHash = OrderedDictionary<NodeValue.ID, Node>
    public typealias Node = GraphNode<NodeValue>
}
