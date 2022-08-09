public class Dependencies<CodeArtifactType: CodeArtifact>
{
    static var empty: Dependencies<CodeArtifactType> { Dependencies<CodeArtifactType>() }
    
    func add(_ otherDependencies: Dependencies<CodeArtifactType>)
    {
        hashMap.merge(otherDependencies.hashMap)
        {
            mine, other in
            
            mine.weight += other.weight
            
            return mine
        }
    }
    
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
    
    // TODO: hash by source for performance
    func outgoing(from artifact: CodeArtifactType) -> [Dependency<CodeArtifactType>]
    {
        Array(hashMap.values.filter { $0.source === artifact })
    }
    
    // TODO: hash by target for performance
    func ingoing(to artifact: CodeArtifactType) -> [Dependency<CodeArtifactType>]
    {
        Array(hashMap.values.filter { $0.target === artifact })
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
