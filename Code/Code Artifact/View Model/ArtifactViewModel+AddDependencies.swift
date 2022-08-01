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
            vm in
            
            guard case .symbol(let symbol) = vm.kind else { return }
            
            vm.incomingDependencies = symbol.incomingDependencies.compactMap
            {
                viewModelHashMap[$0.hash]
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
