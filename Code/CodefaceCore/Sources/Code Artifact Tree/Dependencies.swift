public class Dependencies<CodeArtifactType: CodeArtifact>
{
    func addDependence(from source: CodeArtifactType,
                       to target: CodeArtifactType)
    {
        let dependencyID = dependencyID(forSource: source, target: target)
        
        if let dependency = hashMap[dependencyID]
        {
            dependency.weight += 1
        }
        else
        {
            hashMap[dependencyID] = Dependency(source: source, target: target)
        }
    }
    
    public var all: [Dependency<CodeArtifactType>] { Array(hashMap.values) }
    
    var sources: [CodeArtifactType] { hashMap.values.map { $0.source } }
    var targets: [CodeArtifactType] { hashMap.values.map { $0.target } }
    
    var count: Int { hashMap.count }
    
    private var hashMap = [DependencyID: Dependency<CodeArtifactType>]()
}

public class Dependency<CodeArtifactType: CodeArtifact>
{
    init(source: CodeArtifactType, target: CodeArtifactType)
    {
        self.source = source
        self.target = target
        
        weight = 1
    }
    
    var id: DependencyID { dependencyID(forSource: source, target: target) }
    
    public let source: CodeArtifactType
    public let target: CodeArtifactType
    
    public var weight = 0
}

func dependencyID(forSource source: CodeArtifact,
                  target: CodeArtifact) -> DependencyID
{
    source.id + "_" + target.id
}

typealias DependencyID = String
