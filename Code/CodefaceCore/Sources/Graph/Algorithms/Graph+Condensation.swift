import OrderedCollections
import SwiftyToolz

extension Graph
{
    /**
     Creates the acyclic condensation graph, contracting strongly connected components into single nodes.
     
     See <https://en.wikipedia.org/wiki/Strongly_connected_component>
     */
    func makeCondensation() -> Graph<StronglyConnectedComponent>
    {
        let sccNodeSets = findStronglyConnectedComponents()
        
        // create condensation nodes and a hashmap
        var condensationNodes = Set<CondensationNode>()
        var condensationNodeHash = [Node: CondensationNode]()
        
        for sccNodes in sccNodeSets
        {
            let condensationNode = CondensationNode(value: StronglyConnectedComponent(nodes: sccNodes))
            
            for sccNode in sccNodes
            {
                condensationNodeHash[sccNode] = condensationNode
            }
            
            condensationNodes += condensationNode
        }
        
        // create condensation edges
        var condensationEdges = Set<CondensationEdge>()
        
        for edge in edges
        {
            guard let sourceCN = condensationNodeHash[edge.source],
                  let targetCN = condensationNodeHash[edge.target]
            else
            {
                fatalError("mising scc in hash map")
            }
            
            if sourceCN !== targetCN
            {
                condensationEdges += CondensationEdge(from: sourceCN, to: targetCN)
            }
        }
        
        // create graph
        return .init(nodes: condensationNodes, edges: condensationEdges)
    }
    
    typealias CondensationNode = GraphNode<StronglyConnectedComponent>
    typealias CondensationEdge = GraphEdge<StronglyConnectedComponent>
    
    class StronglyConnectedComponent: Identifiable
    {
        init(nodes: Set<Node>)
        {
            self.nodes = nodes
        }
        
        let nodes: Set<Node>
    }
}
