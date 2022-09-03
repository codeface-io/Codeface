extension CodeArtifact
{
    func goesBefore(_ nextArtifact: CodeArtifact) -> Bool
    {
        // different components?
        if let componentNumA = metrics.componentRank,
           let componentNumB = nextArtifact.metrics.componentRank,
           componentNumA != componentNumB
        {
            return componentNumA < componentNumB
        }
        
        // different topological rank?
        if let topoRankA  = metrics.sccIndexTopologicallySorted,
           let topoRankB  = nextArtifact.metrics.sccIndexTopologicallySorted,
           topoRankA != topoRankB
        {
            return topoRankA < topoRankB
        }
        
        // in- and outgoing dependencies
        if let inA = metrics.ingoingDependenciesInScope,
           let inB = nextArtifact.metrics.ingoingDependenciesInScope,
           inA != inB
        {
            return inA < inB
        }
        
        if let outA = metrics.outgoingDependenciesInScope,
           let outB = nextArtifact.metrics.outgoingDependenciesInScope,
           outA != outB
        {
            return outA < outB
        }
        
        return linesOfCode > nextArtifact.linesOfCode
    }
}
