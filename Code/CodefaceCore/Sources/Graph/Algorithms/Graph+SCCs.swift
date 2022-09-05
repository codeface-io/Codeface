import SwiftyToolz

extension Graph
{
    func findStronglyConnectedComponents() -> Set<Set<Node<NodeContent>>>
    {
        var resultingSCCs = Set<Set<Node<NodeContent>>>()
        
        var markingsHash = [Node<NodeContent>: NodeMarkings]()
        var index = 0
        var stack = [Node<NodeContent>]()
        
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
    private func findSCCsRecursively(node: Node<NodeContent>,
                                     index: inout Int,
                                     stack: inout [Node<NodeContent>],
                                     markingsHash: inout [Node<NodeContent>: NodeMarkings],
                                     handleNewSCC: (Set<Node<NodeContent>>) -> Void) -> NodeMarkings
    {
        // Set the depth index for node to the smallest unused index
        assert(markingsHash[node] == nil, "there shouldn't be a markings object for this node yet")
        let nodeMarkings = NodeMarkings(index: index, lowLink: index)
        index += 1
        stack.append(node)
        nodeMarkings.isOnStack = true
        markingsHash[node] = nodeMarkings
        
        // Consider descendants of node
        for target in descandants(of: node)
        {
            if let targetMarkings = markingsHash[target]
            {
                // If target is not on stack, then edge (node, target) is pointing to an SCC already found and must be ignored
                if targetMarkings.isOnStack
                {
                    // Successor "target" is in stack and hence in the current SCC
                    nodeMarkings.lowLink = min(nodeMarkings.lowLink, targetMarkings.index)
                }
            }
            else // if target index is undefined then
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
            var newSCC = Set<Node<NodeContent>>()
            
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
}
