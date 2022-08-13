import SwiftyToolz

extension Graph
{
    func findTopologicalRanks() -> [Node: Int]
    {
        var nodesToVisit = nodes
        
        var ancestorCountsByNode = [Node: Int]()

        while let nodeToVisit = nodesToVisit.first
        {
            getAncestorCount(for: nodeToVisit,
                             nodesToVisit: &nodesToVisit,
                             results: &ancestorCountsByNode)
        }
        
        return ancestorCountsByNode
    }

    @discardableResult
    private func getAncestorCount(for node: Node,
                                  nodesToVisit: inout Set<Node>,
                                  results: inout [Node: Int]) -> Int
    {
        if !nodesToVisit.contains(node) { return results[node] ?? 0 }
        else { nodesToVisit -= node }
        
        let directAncestors = edges.ingoing(to: node).map { $0.source }
        
        let ancestorCount = directAncestors.count + directAncestors.sum
        {
            getAncestorCount(for: $0,
                             nodesToVisit: &nodesToVisit,
                             results: &results)
        }
        
        results[node] = ancestorCount
        
        return ancestorCount
    }
}
