import SwiftyToolz

extension Graph
{
    // create acyclic graph, condensing strongly connected components into single nodes
    func condensedAssumingConnectedness() -> Graph<CondensedNode>
    {
        let stronglyConnectedComponents = findStronglyConnectedComponents()
        
        // create condensed nodes and a hashmap
        var condensedNodes = Set<CondensedNode>()
        var condensedNodeHash = [Node: CondensedNode]()
        
        for scc in stronglyConnectedComponents
        {
            let condensedNode = CondensedNode(stronglyConnectedNodes: scc)
            
            for sccNode in scc
            {
                condensedNodeHash[sccNode] = condensedNode
            }
            
            condensedNodes += condensedNode
        }
        
        // create condensed edges
        var condensedEdges = Edges<CondensedNode>()
        
        for edge in edges.all
        {
            guard let sourceSCC = condensedNodeHash[edge.source],
                  let targetSCC = condensedNodeHash[edge.target]
            else
            {
                fatalError("found no scc in hash map")
            }
            
            if sourceSCC !== targetSCC
            {
                condensedEdges.addEdge(from: sourceSCC, to: targetSCC)
            }
        }
        
        // create graph
        return .init(nodes: condensedNodes, edges: condensedEdges)
    }
    
    class CondensedNode: Hashable, Identifiable
    {
        init(stronglyConnectedNodes: Set<Node>)
        {
            self.stronglyConnectedNodes = stronglyConnectedNodes
        }
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self))
        }
        
        static func == (lhs: CondensedNode, rhs: CondensedNode) -> Bool
        {
            lhs === rhs
        }
        
        let stronglyConnectedNodes: Set<Node>
    }
    
    
    func findStronglyConnectedComponents() -> [Set<Node>]
    {
        var resultingSCCs = [Set<Node>]()
        
        var markingsHash = [Node: NodeMarkings]()
        var index = 0
        var stack = [Node]()
        
        for node in nodes
        {
            if markingsHash[node] == nil
            {
                findSCCsRecursively(node: node,
                                    index: &index,
                                    stack: &stack,
                                    markingsHash: &markingsHash) { resultingSCCs += $0 }
            }
        }
        
        return resultingSCCs
    }
    
    @discardableResult
    private func findSCCsRecursively(node: Node,
                                     index: inout Int,
                                     stack: inout [Node],
                                     markingsHash: inout [Node: NodeMarkings],
                                     handleNewSCC: (Set<Node>) -> Void) -> NodeMarkings
    {
        // Set the depth index for node to the smallest unused index
        assert(markingsHash[node] == nil, "there shouldn't be a markings object for this node yet")
        let nodeMarkings = NodeMarkings(index: index, lowLink: index)
        index += 1
        stack.append(node)
        nodeMarkings.isOnStack = true
        markingsHash[node] = nodeMarkings
        
        // Consider successors of node
        for target in edges.outgoing(from: node).map({ $0.target })
        {
            if let targetMarkings = markingsHash[target]
            {
                if targetMarkings.isOnStack
                {
                    // Successor w is in stack S and hence in the current SCC
                    // If w is not on stack, then (v, w) is an edge pointing to an SCC already found and must be ignored
                    // Note: The next line may look odd - but is correct.
                    // It says w.index not w.lowlink; that is deliberate and from the original paper
                    
                    nodeMarkings.lowLink = min(nodeMarkings.lowLink, targetMarkings.index)
                }
            }
            else // if target.index is undefined then
            {
                // Successor "target" has not yet been visited; recurse on it
                let targetMarkings = findSCCsRecursively(node: target,
                                                   index: &index,
                                                   stack: &stack,
                                                   markingsHash: &markingsHash,
                                                   handleNewSCC: handleNewSCC)
                
                nodeMarkings.lowLink = min(nodeMarkings.lowLink, targetMarkings.lowLink)
            }
        }
        
        // If node is a root node, pop the stack and generate an SCC
        if nodeMarkings.lowLink == nodeMarkings.index
        {
            var newSCC = Set<Node>()
            
            while !stack.isEmpty
            {
                let sccNode = stack.removeLast()
                
                guard let sccNodeMarkings = markingsHash[sccNode] else
                {
                    fatalError("node that is on the stack should have a markings object")
                }
                
                sccNodeMarkings.isOnStack = false
                newSCC += sccNode
                
                if node === sccNode { break }
            }

            handleNewSCC(newSCC)
        }
        
        return nodeMarkings
    }
    
    private class NodeMarkings
    {
        init(index: Int, lowLink: Int)
        {
            self.index = index
            self.lowLink = lowLink
        }
        
        var index: Int
        var lowLink: Int
        var isOnStack = false
    }
    
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
