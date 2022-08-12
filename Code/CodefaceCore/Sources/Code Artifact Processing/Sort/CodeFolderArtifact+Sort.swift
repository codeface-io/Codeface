public extension CodeFolderArtifact
{
    func sort()
    {
        for part in parts
        {
            switch part.kind
            {
            case .subfolder(let folder): folder.sort()
            case .file(let file): file.sort()
            }
        }
        
        partsByArtifactHash.values.sort()
    }
}

extension CodeFolderArtifact.PartNode: Comparable
{
    public static func < (lhs: CodeFolderArtifact.PartNode,
                          rhs: CodeFolderArtifact.PartNode) -> Bool
    {
        // different components?
        if let componentNumA = lhs.metrics.componentRank,
           let componentNumB = rhs.metrics.componentRank,
           componentNumA != componentNumB
        {
            return componentNumA < componentNumB
        }
        
        // different topological rank?
        if let topoRankA  = lhs.metrics.topologicalRankInComponent,
           let topoRankB  = rhs.metrics.topologicalRankInComponent,
           topoRankA != topoRankB
        {
            return topoRankA < topoRankB
        }
        
        // in- and outgoing dependencies
        if let inA = lhs.metrics.ingoingDependenciesInScope,
           let inB = rhs.metrics.ingoingDependenciesInScope,
           inA != inB
        {
            return inA < inB
        }
        
        if let outA = lhs.metrics.outgoingDependenciesInScope,
           let outB = rhs.metrics.outgoingDependenciesInScope,
           outA != outB
        {
            return outA < outB
        }
        
//        if lhs.dependencyDifferenceExternal != rhs.dependencyDifferenceExternal
//        {
//            return lhs.dependencyDifferenceExternal > rhs.dependencyDifferenceExternal
//        }
        
        return lhs.linesOfCode > rhs.linesOfCode
    }
}
