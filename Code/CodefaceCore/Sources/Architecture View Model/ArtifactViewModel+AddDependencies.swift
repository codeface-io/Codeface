import SwiftyToolz

public extension ArtifactViewModel
{
    func addDependencies()
    {
        // make view model hash map
        var viewModelHashMap = [CodeArtifact.ID : ArtifactViewModel]()
        
        applyRecursively
        {
            viewModelHashMap[$0.codeArtifact.id] = $0
        }
        
        // add view models for dependencies
        applyRecursively
        {
            artifactVM in
            
            // TODO: generalize this instead of repeating code for each kind
            
            switch artifactVM.kind
            {
            case .folder(let folder):
                for dependency in folder.partGraph.edges
                {
                    guard let originVM = viewModelHashMap[dependency.origin.value.id],
                          let destinationVM = viewModelHashMap[dependency.destination.value.id]
                    else
                    {
                        log(error: "Could not find VMs for dependency from \(dependency.origin.value.kindName) to \(dependency.destination.value.kindName)")
                        continue
                    }
                    
                    artifactVM.partDependencies += .init(sourcePart: originVM,
                                                         targetPart: destinationVM,
                                                         weight: dependency.count)
                }
                
            case .file(let file):
                for dependency in file.symbolGraph.edges
                {
                    guard let originVM = viewModelHashMap[dependency.origin.value.id],
                          let destinationVM = viewModelHashMap[dependency.destination.value.id]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: originVM,
                                                         targetPart: destinationVM,
                                                         weight: dependency.count)
                }
                
            case .symbol(let symbol):
                for dependency in symbol.subsymbolGraph.edges
                {
                    guard let originVM = viewModelHashMap[dependency.origin.value.id],
                          let destinationVM = viewModelHashMap[dependency.destination.value.id]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: originVM,
                                                         targetPart: destinationVM,
                                                         weight: dependency.count)
                }
            }
        }
    }

    func applyRecursively(action: (ArtifactViewModel) -> Void)
    {
        parts.forEach { $0.applyRecursively(action: action) }
        action(self)
    }
}
