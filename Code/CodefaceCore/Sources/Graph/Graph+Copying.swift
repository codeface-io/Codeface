import SwiftyToolz

extension Graph
{
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
    
    /// Make a copy of (a subset of) the graph
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
}
