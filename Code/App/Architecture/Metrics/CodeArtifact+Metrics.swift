import SwiftyToolz

@BackgroundActor
extension CodeArtifact
{
    var linesOfCode: Int { metrics.linesOfCode ?? 0 }
    
    var metrics: Metrics
    {
        get { CodeArtifactMetricsCache.shared[id] }
        set { CodeArtifactMetricsCache.shared[id] = newValue }
    }
}
