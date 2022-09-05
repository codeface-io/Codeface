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
        
        let sourceNodes = allNodes.filter { ancestors(of: $0).count == 0 }
        
        for sourceNode in sourceNodes
        {
            // TODO: keep track of visited nodes within each traversal from a source and ignore already visited nodes so we can't get hung up in cycles
            
            let reachabilities = findIndirectReachabilities(around: sourceNode,
                                                            reachedAncestors: [],
                                                            consideredAncestorsHash: &consideredAncestorsHash)
            
            indirectReachabilities.add(reachabilities)
        }
        
        return removing(indirectReachabilities) 
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
        
        let descendants = descandants(of: node)
        
        for ancestor in ancestorsToConsider
        {
            for descendant in descendants
            {
                indirectReachabilities.addEdge(from: ancestor, to: descendant)
            }
        }
        
        // recursive calls on descendants
        
        for descendant in descendants
        {
            indirectReachabilities.add(findIndirectReachabilities(around: descendant,
                                                                  reachedAncestors: ancestorsToConsider + node,
                                                                  consideredAncestorsHash: &consideredAncestorsHash))
        }
        
        return indirectReachabilities
    }
}
