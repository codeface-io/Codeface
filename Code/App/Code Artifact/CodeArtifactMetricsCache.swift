@BackgroundActor
public class CodeArtifactMetricsCache
{
    public static let shared = CodeArtifactMetricsCache()
    
    public func clear()
    {
        metricsByArtifactID.removeAll()
    }
    
    /// Since `Metrics` is a value type, the getter simply returns a new value when none is stored
    public subscript(_ id: CodeArtifact.ID) -> Metrics
    {
        get { metricsByArtifactID[id] ?? Metrics() }
        set { metricsByArtifactID[id] = newValue }
    }
    
    private var metricsByArtifactID = [CodeArtifact.ID: Metrics]()
}
