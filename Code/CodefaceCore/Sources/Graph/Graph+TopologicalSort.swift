import SwiftyToolz

extension Graph
{
    func findNumberOfNodeAncestors() -> [(Node, Int)]
    {
        var nodesToVisit = nodes
        
        var ancestorCountsByNode = [Node: Int]()

        while let nodeToVisit = nodesToVisit.first
        {
            getAncestorCount(for: nodeToVisit,
                             nodesToVisit: &nodesToVisit,
                             results: &ancestorCountsByNode)
        }

        return ancestorCountsByNode.map { ($0.key, $0.value) }
    }

    @discardableResult
    private func getAncestorCount(for node: Node,
                                  nodesToVisit: inout Set<Node>,
                                  results: inout [Node: Int]) -> Int
    {
        if !nodesToVisit.contains(node) { return results[node] ?? 0 }
        else { nodesToVisit -= node }
        
        let ingoingEdges = edges.ingoing(to: node)
        let directAncestors = ingoingEdges.map { $0.source }
        let directAncestorCount = ingoingEdges.sum { $0.count }
        
        let ancestorCount = directAncestorCount + directAncestors.sum
        {
            getAncestorCount(for: $0,
                             nodesToVisit: &nodesToVisit,
                             results: &results)
        }
        
        results[node] = ancestorCount
        
        return ancestorCount
    }
}
