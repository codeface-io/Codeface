import SwiftyToolz

// TODO: for all algorithms: make use of possibility to mark nodes directly
// TODO: Then extract graph into its own open-source package

extension Graph
{
    /**
     Finds the total number of all ancestors (predecessors / sources) for every node of an **acyclic** graph.
     */
    func findNumberOfNodeAncestors() -> [(Node, Int)]
    {
        var ancestorCountsByNode = [Node: Int]()
        
        for sinkNode in sinks
        {
            getAncestorCount(for: sinkNode, results: &ancestorCountsByNode)
        }

        return ancestorCountsByNode.map { ($0.key, $0.value) }
    }

    @discardableResult
    private func getAncestorCount(for node: Node,
                                  results: inout [Node: Int]) -> Int
    {
        if let ancestors = results[node] { return ancestors }
        
        results[node] = 0 // marks the node as visited to avoid infinite loops in cyclic graphs
        
        let directAncestors = node.ancestors
        let ingoingEdges = directAncestors.compactMap { edge(from: $0, to: node) }
        let directAncestorCount = ingoingEdges.sum { $0.count }
        
        let ancestorCount = directAncestorCount + directAncestors.sum
        {
            getAncestorCount(for: $0, results: &results)
        }
        
        results[node] = ancestorCount
        
        return ancestorCount
    }
}
