import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    func calculateSortMetricsRecursively()
    {
        // depth first! this is important
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                subfolder.calculateSortMetricsRecursively()
            case .file(let file):
                file.calculateSortMetricsRecursively()
            }
        }
        
        partGraph.calculateSortMetrics()
    }
}

@BackgroundActor
private extension CodeFileArtifact
{
    func calculateSortMetricsRecursively()
    {
        symbolGraph.values.forEach { $0.calculateSortMetricsRecursively() }
        
        symbolGraph.calculateSortMetrics()
    }
}

@BackgroundActor
private extension CodeSymbolArtifact
{
    func calculateSortMetricsRecursively()
    {
        subsymbolGraph.values.forEach { $0.calculateSortMetricsRecursively() }
        
        subsymbolGraph.calculateSortMetrics()
    }
}

@BackgroundActor
private extension Graph where NodeValue: CodeArtifact & Identifiable, NodeID == CodeArtifact.ID
{
    func calculateSortMetrics()
    {
        nodes
            .sorted
            {
                $0.goesBefore($1)
            }
            .forEachIndex
            {
                node, nodeIndex in
                
                node.value.metrics.sortRank = nodeIndex
            }
    }
}
