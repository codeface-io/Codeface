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
        
        // different ratios of ingoing to outgoing dependencies?
        let inA = ancestorIDs.count
        let outA = descendantIDs.count
        
        let inB = nextNode.ancestorIDs.count
        let outB = nextNode.descendantIDs.count
        
        if inA + outA + inB + outB > 0
        {
            let ratioA = Double(inA + 1) / Double(outA + 1)
            let ratioB = Double(inB + 1) / Double(outB + 1)
            
            if ratioA != ratioB
            {
                return ratioA < ratioB
            }
        }
        
        // different positions in code?
        if let symbolA = thisArtifact as? CodeSymbolArtifact,
           let symbolB = nextArtifact as? CodeSymbolArtifact,
           symbolA.selectionRange.start.line != symbolB.selectionRange.start.line
        {
            
            return symbolA.selectionRange.start.line < symbolB.selectionRange.start.line
        }
        
        // different sizes?
        if thisArtifact.linesOfCode != nextArtifact.linesOfCode
        {
            return thisArtifact.linesOfCode > nextArtifact.linesOfCode
        }
        
        // ultima ratio: sort by name
        return thisArtifact.name < nextArtifact.name
    }
}
