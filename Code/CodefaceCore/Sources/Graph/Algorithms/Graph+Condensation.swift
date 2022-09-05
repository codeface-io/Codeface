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
        let stronglyConnectedComponents = findStronglyConnectedComponents()
        
        // create condensation nodes and a hashmap
        var condensationNodes = OrderedSet<CondensationNode>()
        var condensationNodeHash = [Node: CondensationNode]()
        
        for scc in stronglyConnectedComponents
        {
            let condensationNode = CondensationNode(value: StronglyConnectedComponent(nodes: scc))
            
            for sccNode in scc
            {
                condensationNodeHash[sccNode] = condensationNode
            }
            
            condensationNodes.append(condensationNode)
        }
        
        // create condensation edges
        var condensationEdges = Edges<StronglyConnectedComponent>()
        
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
                condensationEdges.addEdge(from: sourceCN, to: targetCN)
            }
        }
        
        // create graph
        return .init(nodes: condensationNodes, edges: condensationEdges)
    }
    
    typealias CondensationNode = GraphNode<StronglyConnectedComponent>
    
    class StronglyConnectedComponent: Hashable, Identifiable
    {
        init(nodes: Set<Node>)
        {
            self.nodes = nodes
        }
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self))
        }
        
        static func == (lhs: StronglyConnectedComponent,
                        rhs: StronglyConnectedComponent) -> Bool
        {
            lhs === rhs
        }
        
        let nodes: Set<Node>
    }
}
