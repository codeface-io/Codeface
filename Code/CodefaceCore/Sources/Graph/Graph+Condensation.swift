import SwiftyToolz

extension Graph
{
    /**
     Creates the acyclic condensation graph, contracting strongly connected components into single nodes.
     
     See <https://en.wikipedia.org/wiki/Strongly_connected_component>
     */
    func makeCondensation() -> Graph<CondensationNode>
    {
        let stronglyConnectedComponents = findStronglyConnectedComponents()
        
        // create condensation nodes and a hashmap
        var condensationNodes = Set<CondensationNode>()
        var condensationNodeHash = [NodeContent: CondensationNode]()
        
        for scc in stronglyConnectedComponents
        {
            let condensationNode = CondensationNode(stronglyConnectedComponent: scc)
            
            for sccNode in scc
            {
                condensationNodeHash[sccNode] = condensationNode
            }
            
            condensationNodes += condensationNode
        }
        
        // create condensation edges
        var condensationEdges = Edges<CondensationNode>()
        
        for edge in allEdges
        {
            guard let sourceCN = condensationNodeHash[edge.source],
                  let targetCN = condensationNodeHash[edge.target]
            else
            {
                fatalError("mising scc in hash map")
            }
            
            if sourceCN !== targetCN
            {
                condensationEdges.addEdge(from: sourceCN, to: targetCN)
            }
        }
        
        // create graph
        return .init(nodes: condensationNodes, edges: condensationEdges)
    }
    
    class CondensationNode: Hashable, Identifiable
    {
        init(stronglyConnectedComponent: Set<NodeContent>)
        {
            self.stronglyConnectedComponent = stronglyConnectedComponent
        }
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self))
        }
        
        static func == (lhs: CondensationNode, rhs: CondensationNode) -> Bool
        {
            lhs === rhs
        }
        
        let stronglyConnectedComponent: Set<NodeContent>
    }
}
