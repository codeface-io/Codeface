@BackgroundActor
extension CodeFolderArtifact
{
    func calculateCycleMetricsRecursively()
    {
        traverseDepthFirst { $0.calculateCycleMetrics() }
    }
}

@BackgroundActor
private extension CodeArtifact
{
    func calculateCycleMetrics()
    {
        metrics.linesOfCodeOfPartsInCycles = parts.sum { $0.metrics.linesOfCodeInCycles }
    }
}
