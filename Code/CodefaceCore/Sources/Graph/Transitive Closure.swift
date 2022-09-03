import SwiftyToolz

extension Graph
{
    /// This stub will not work on cyclic graphs and is also incomplete on acyclic graphs since it doesn't handle encounters with nodes it already has visited ...
    /*
    func findTransitiveClosure() -> Edges<Node>
    {
        var closure = Edges<Node>()
        
        var nodesToVisit = nodes
        
        while let startNode = nodesToVisit.first
        {
            closure.add(findTransitiveEdges(reachableFrom: startNode,
                                            reachedNodes: [],
                                            nodesToVisit: &nodesToVisit))
        }
        
        return closure
    }
    
    private func findTransitiveEdges(reachableFrom startNode: Node,
                                     reachedNodes: Set<Node>,
                                     nodesToVisit: inout Set<Node>) -> Edges<Node>
    {
        var foundEdges = Edges<Node>()
        
        // base case: add edges from all reached sources to all reachable neighbours of start node
        
        let reachableNeighbours = edges.outgoing(from: startNode).map { $0.target }
        
        for reachedNode in reachedNodes
        {
            for reachableNeighbour in reachableNeighbours
            {
                foundEdges.addEdge(from: reachedNode, to: reachableNeighbour)
            }
        }
        
        nodesToVisit -= startNode
        
        // recursive calls on reachable neighbours
        
        for reachableNeighbour in reachableNeighbours
        {
            foundEdges.add(findTransitiveEdges(reachableFrom: reachableNeighbour,
                                               reachedNodes: reachedNodes + startNode,
                                               nodesToVisit: &nodesToVisit))
        }
        
        return foundEdges
    }
     */
}
