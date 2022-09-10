import Combine
import OrderedCollections

public class PathBar: ObservableObject
{
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
