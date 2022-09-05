import SwiftyToolz

extension Graph
{
    func findComponents() -> Set<Set<NodeContent>>
    {
        var nodesToSearch = allNodes
        var components = Set<Set<NodeContent>>()

        while let nodeToSearch = nodesToSearch.first
        {
            let nextComponent = findLackingNodes(forComponent: [],
                                                 startingAt: nodeToSearch)
            components += nextComponent
            nodesToSearch -= nextComponent
        }

        return components
    }
    
    private func findLackingNodes(forComponent incompleteComponent: Set<NodeContent>,
                                  startingAt node: NodeContent) -> Set<NodeContent>
    {
        guard !incompleteComponent.contains(node) else { return [] }
        
        var lackingNodes: Set<NodeContent> = [node]
        
        let neighbours = descandants(of: node) + ancestors(of: node)
        
        for neighbour in neighbours
        {
            let extendedComponent = incompleteComponent + lackingNodes
            lackingNodes += findLackingNodes(forComponent: extendedComponent,
                                             startingAt: neighbour)
        }
        
        return lackingNodes
    }
}
