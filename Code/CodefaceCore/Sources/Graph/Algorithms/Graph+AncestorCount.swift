import SwiftyToolz

extension Graph
{
    /**
     Finds the total number of all ancestors (predecessors / sources) for every node of an **acyclic** graph.
     */
    func findNumberOfNodeAncestors() -> [(Node<NodeContent>, Int)]
    {
        var ancestorCountsByNode = [Node<NodeContent>: Int]()
        
        let sinkNodes = nodes.filter { descandants(of: $0).count == 0 }

        for sinkNode in sinkNodes
        {
            getAncestorCount(for: sinkNode, results: &ancestorCountsByNode)
        }

        return ancestorCountsByNode.map { ($0.key, $0.value) }
    }

    @discardableResult
    private func getAncestorCount(for node: Node<NodeContent>,
                                  results: inout [Node<NodeContent>: Int]) -> Int
    {
        if let ancestors = results[node] { return ancestors }
        
        results[node] = 0 // marks the node as visited to avoid infinite loops in cyclic graphs
        
        let ingoingEdges = ingoingEdges(to: node)
        let directAncestors = ingoingEdges.map { $0.source }
        let directAncestorCount = ingoingEdges.sum { $0.count }
        
        let ancestorCount = directAncestorCount + directAncestors.sum
        {
            getAncestorCount(for: $0, results: &results)
        }
        
        results[node] = ancestorCount
        
        return ancestorCount
    }
}
