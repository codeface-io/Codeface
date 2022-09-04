import SwiftyToolz

extension Graph
{
    /**
     Finds the minumum equivalent graph of an **acyclic** graph.
     
     🛑 If the graph is cyclic, this algorithm might hang or crash!
     
     See <https://en.wikipedia.org/wiki/Transitive_reduction>
     */
    func makeMinimumEquivalentGraph() -> Graph<Node>
    {
        var indirectReachabilities = Edges<Node>()
        var consideredAncestorsHash = [Node: Set<Node>]()
        
        let sourceNodes = nodes.filter { edges.ingoing(to: $0).count == 0 }
        
        for sourceNode in sourceNodes
        {
            // TODO: keep track of visited nodes within each traversal from a source and ignore already visited nodes so we couldn't get hung up in cycles
            
            let reachabilities = findIndirectReachabilities(around: sourceNode,
                                                            reachedAncestors: [],
                                                            consideredAncestorsHash: &consideredAncestorsHash)
            
            indirectReachabilities.add(reachabilities)
        }
        
        return Graph(nodes: nodes,
                     edges: edges.removing(indirectReachabilities)) 
    }
    
    private func findIndirectReachabilities(around node: Node,
                                            reachedAncestors: Set<Node>,
                                            consideredAncestorsHash: inout [Node: Set<Node>]) -> Edges<Node>
    {
        let consideredAncestors = consideredAncestorsHash[node, default: Set<Node>()]
        let ancestorsToConsider = reachedAncestors - consideredAncestors
        
        if !reachedAncestors.isEmpty && ancestorsToConsider.isEmpty
        {
            // found shortcut edge on a path we've already traversed, so we reached no new ancestors
            return .empty
        }
        
        consideredAncestorsHash[node, default: Set<Node>()] += ancestorsToConsider
        
        var indirectReachabilities = Edges<Node>()
        
        // base case: add edges from all reached ancestors to all reachable neighbours of node
        
        let reachableNeighbours = edges.outgoing(from: node).map { $0.target }
        
        for ancestor in ancestorsToConsider
        {
            for reachableNeighbour in reachableNeighbours
            {
                indirectReachabilities.addEdge(from: ancestor, to: reachableNeighbour)
            }
        }
        
        // recursive calls on reachable neighbours
        
        for reachableNeighbour in reachableNeighbours
        {
            indirectReachabilities.add(findIndirectReachabilities(around: reachableNeighbour,
                                                                  reachedAncestors: ancestorsToConsider + node,
                                                                  consideredAncestorsHash: &consideredAncestorsHash))
        }
        
        return indirectReachabilities
    }
}
