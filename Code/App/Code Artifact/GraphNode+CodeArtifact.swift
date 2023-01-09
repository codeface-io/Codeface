import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension GraphNode where Value: CodeArtifact
{
    func goesBefore(_ nextNode: Node) -> Bool
    {
        let nextArtifact = nextNode.value
        let thisArtifact = value
        
        // different components?
        if let componentNumA = thisArtifact.metrics.componentRank,
           let componentNumB = nextArtifact.metrics.componentRank,
           componentNumA != componentNumB
        {
            return componentNumA < componentNumB
        }
        
        // different topological rank?
        if let topoRankA  = thisArtifact.metrics.sccIndexTopologicallySorted,
           let topoRankB  = nextArtifact.metrics.sccIndexTopologicallySorted,
           topoRankA != topoRankB
        {
            return topoRankA < topoRankB
        }
        
        // in- and outgoing dependencies
        let inA = ancestorIDs.count
        let inB = nextNode.ancestorIDs.count
        
        if inA != inB
        {
            return inA < inB
        }
        
        let outA = descendantIDs.count
        let outB = nextNode.descendantIDs.count
        
        if outA != outB
        {
            return outA < outB
        }
        
        return thisArtifact.linesOfCode > nextArtifact.linesOfCode
    }
}
