import CodefaceCore
import SwiftyToolz

extension ArtifactViewModel
{
    func addDependencies() -> ArtifactViewModel
    {
        // make view model hash map
        var viewModelHashMap = [CodeArtifact.Hash : ArtifactViewModel]()
        applyRecursively { viewModelHashMap[$0.codeArtifact.hash] = $0 }
        
        // connect view models for symbol dependencies
        applyRecursively
        {
            artifactVM in
            
            for subVM in artifactVM.parts
            {
                guard case .symbol(let subsymbol) = subVM.kind else { return }
                
                for dependingSubsymbol in subsymbol.incomingDependenciesScope
                {
                    guard let dependingSubsymbolVM = viewModelHashMap[dependingSubsymbol.hash]
                    else { continue }
                    
                    artifactVM.partDependencies += .init(sourcePart: dependingSubsymbolVM,
                                                         targetPart: subVM)
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
