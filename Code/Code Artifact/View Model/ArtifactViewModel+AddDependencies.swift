extension ArtifactViewModel
{
    func addDependencies() -> ArtifactViewModel
    {
        // make view model hash map
        var viewModelHashMap = [CodeArtifact.Hash : ArtifactViewModel]()
        applyRecursively { viewModelHashMap[$0.codeArtifact.hash] = $0 }
        
//        print("did create hash map for \(viewModelHashMap.count) view models")
        
        // connect view models for symbol dependencies
        applyRecursively
        {
            vm in
            
            guard case .symbol(let symbol) = vm.kind else { return }
            
//            print("found view model for symbol with \(symbol.incomingDependencies.count) incoming dependencies")
            
            vm.incomingDependencies = symbol.incomingDependencies.compactMap
            {
                viewModelHashMap[$0.hash]
            }
            
//            print("did set \(vm.incomingDependencies.count) incoming dependencies in view model")
        }
        
        return self
    }

    func applyRecursively(action: (ArtifactViewModel) -> Void)
    {
        parts.forEach { $0.applyRecursively(action: action) }
        action(self)
    }
}
