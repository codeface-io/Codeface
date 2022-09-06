import SwiftyToolz

extension Graph
{
    func findComponents() -> Set<Set<Node>>
    {
        var nodesToSearch = Set(nodes)
        var components = Set<Set<Node>>()

        while let nodeToSearch = nodesToSearch.first
        {
            let nextComponent = findLackingNodes(forComponent: [],
                                                 startingAt: nodeToSearch)
            components += nextComponent
            nodesToSearch -= nextComponent
        }

        return components
    }
    
    private func findLackingNodes(forComponent incompleteComponent: Set<Node>,
                                  startingAt node: Node) -> Set<Node>
    {
        guard !incompleteComponent.contains(node) else { return [] }
        
        var lackingNodes: Set<Node> = [node]
        
        for neighbour in node.neighbours
        {
            let extendedComponent = incompleteComponent + lackingNodes
            lackingNodes += findLackingNodes(forComponent: extendedComponent,
                                             startingAt: neighbour)
        }
        
        return lackingNodes
    }
}
