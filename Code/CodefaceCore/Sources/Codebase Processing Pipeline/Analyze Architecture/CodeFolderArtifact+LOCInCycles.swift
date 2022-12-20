public extension CodeFolderArtifact
{
    func calculateCycleMetricsRecursively()
    {
        traverseDepthFirst { $0.calculateCycleMetrics() }
    }
}

private extension CodeArtifact
{
    func calculateCycleMetrics()
    {
        metrics.linesOfCodeOfPartsInCycles = parts.sum { $0.metrics.linesOfCodeInCycles }
    }
}
