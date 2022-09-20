import Combine
import OrderedCollections

@MainActor
public class PathBar: ObservableObject
{
    public func select(_ artifactVM: ArtifactViewModel?)
    {
        artifactVMStack.elements = artifactVM?.getPath() ?? []
    }
    
    public func add(_ artifactVM: ArtifactViewModel)
    {
        remove(artifactVM)
        
        artifactVMStack.append(artifactVM)
    }
    
    public func remove(_ artifactVM: ArtifactViewModel)
    {
        if let firstIndex = artifactVMStack.firstIndex(of: artifactVM)
        {
            let lastIndex = artifactVMStack.count - 1
            artifactVMStack.removeSubrange(firstIndex ... lastIndex)
        }
    }
    
    @Published public private(set) var artifactVMStack = OrderedSet<ArtifactViewModel>()
}

private extension ArtifactViewModel
{
    func getPath() -> [ArtifactViewModel]
    {
        (scope?.getPath() ?? []) + [self]
    }
}
