@BackgroundActor
public extension CodeFolderArtifact
{
    func calculateSizeMetricsRecursively()
    {
        traverseDepthFirst { $0.calculateSizeMetrics() }
    }
}

@BackgroundActor
private extension CodeArtifact
{
    func calculateSizeMetrics()
    {
        let locOfParts = parts.sum { $0.linesOfCode }
        
        metrics.linesOfCodeOfParts = locOfParts
        
        parts.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfParts)
        }
        
        metrics.linesOfCode = intrinsicSizeInLinesOfCode ?? locOfParts
    }
}
