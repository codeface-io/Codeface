@BackgroundActor
public class ArtifactMetricCache
{
    public static let shared = ArtifactMetricCache()
    
    public func clear()
    {
        metricsByArtifactID.removeAll()
    }
    
    public subscript(_ id: CodeArtifact.ID) -> Metrics
    {
        get
        {
            /// as long as `Metrics` is a value type we can simply return a new value when none is stored
            
            metricsByArtifactID[id] ?? Metrics()
        }
        
        set { metricsByArtifactID[id] = newValue }
    }
    
    public func set(_ metrics: Metrics, for id: CodeArtifact.ID)
    {
        metricsByArtifactID[id] = metrics
    }
    
    private var metricsByArtifactID = [CodeArtifact.ID : Metrics]()
}
