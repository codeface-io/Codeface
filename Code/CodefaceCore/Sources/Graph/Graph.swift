struct Graph<Node: Hashable & IdentifiableObject>
{
    let nodes: Set<Node>
    let edges: Edges<Node>
}
