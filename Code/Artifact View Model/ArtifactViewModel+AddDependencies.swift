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
        
        // connect view models for symbol dependencies
        applyRecursively
        {
            artifactVM in
            
            guard let symbolDependencies = artifactVM.symbolDependencies else { return }
            
            for dependency in symbolDependencies.all
            {
                guard let sourceVM = viewModelHashMap[dependency.source.hash],
                      let targetVM = viewModelHashMap[dependency.target.hash]
                else { continue }
                
                artifactVM.partDependencies += .init(sourcePart: sourceVM,
                                                     targetPart: targetVM,
                                                     weight: dependency.count)
            }
        }
        
        return self
    }
    
    private var symbolDependencies: Edges<CodeSymbolArtifact, CodeSymbolArtifact>?
    {
        switch kind
        {
        case .symbol(let symbol): return symbol.subsymbolDependencies
        case .file(let file): return file.symbolDependencies
        case .folder: return nil
        }
    }

    func applyRecursively(action: (ArtifactViewModel) -> Void)
    {
        parts.forEach { $0.applyRecursively(action: action) }
        action(self)
    }
}
