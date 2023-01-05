extension CodeArtifact
{
    @BackgroundActor
    var metrics: Metrics
    {
        get { CodeArtifactMetricsCache.shared[id] }
        set { CodeArtifactMetricsCache.shared[id] = newValue }
    }
}

@BackgroundActor
class CodeArtifactMetricsCache
{
    static let shared = CodeArtifactMetricsCache()
    
    func clear()
    {
        metricsByArtifactID.removeAll()
    }
    
    /// Since `Metrics` is a value type, the getter simply returns a new value when none is stored
    subscript(_ id: CodeArtifact.ID) -> Metrics
    {
        get { metricsByArtifactID[id] ?? Metrics() }
        set { metricsByArtifactID[id] = newValue }
    }
    
    private var metricsByArtifactID = [CodeArtifact.ID: Metrics]()
}
