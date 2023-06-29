import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    func calculateMetrics()
    {
        // the order here matters as some steps build upon metrics of preceding ones
        calculateSizeMetricsRecursively()
        calculateDependencyMetricsRecursively()
        calculateCycleMetricsRecursively()
        calculateSortMetricsRecursively()
    }
}
