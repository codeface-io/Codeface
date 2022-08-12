import CodefaceCore
import SwiftyToolz

extension ArtifactViewModel
{
    func addDependencies() -> ArtifactViewModel
    {
        // make view model hash map
        var viewModelHashMap = [CodeArtifact.Hash : ArtifactViewModel]()
        
        applyRecursively
        {
            viewModelHashMap[$0.codeArtifact.hash] = $0
        }
        
        // add view models for dependencies
        applyRecursively
        {
            artifactVM in
            
            // TODO: generalize this instead of repeating code for each kind
            
            switch artifactVM.kind
            {
            case .folder(let folder):
                for dependency in folder.partDependencies.all
                {
                    guard let sourceVM = viewModelHashMap[dependency.source.hash],
                          let targetVM = viewModelHashMap[dependency.target.hash]
                    else
                    {
                        log(error: "Could not find VMs for dependency from \(dependency.source.kindName) to \(dependency.target.kindName)")
                        continue
                    }
                    
                    artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                         targetPart: targetVM,
                                                         weight: dependency.count)
                }
                
            case .file(let file):
                for dependency in file.symbolDependencies.all
                {
                    guard let sourceVM = viewModelHashMap[dependency.source.hash],
                          let targetVM = viewModelHashMap[dependency.target.hash]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                         targetPart: targetVM,
                                                         weight: dependency.count)
                }
                
            case .symbol(let symbol):
                for dependency in symbol.subsymbolDependencies.all
                {
                    guard let sourceVM = viewModelHashMap[dependency.source.hash],
                          let targetVM = viewModelHashMap[dependency.target.hash]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                         targetPart: targetVM,
                                                         weight: dependency.count)
                }
            }
        }
        
        return self
    }

    func applyRecursively(action: (ArtifactViewModel) -> Void)
    {
        parts.forEach { $0.applyRecursively(action: action) }
        action(self)
    }
}
