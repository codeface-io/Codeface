import Combine

@MainActor
class PathBar: ObservableObject
{
    // MARK: - Initialize
    
    init(selectionPublisher: any Publisher<ArtifactViewModel, Never>)
    {
        self.selectionPublisher = selectionPublisher
        observeSelection()
    }
    
    // MARK: - Observe Root Selection
    
    private func observeSelection()
    {
        // TODO: does this really fire immediately since the unnderlying publisher is a CurrentValueSubject? Otherwise we wouldn't receive then initial selection ...
        observation = selectionPublisher.sink
        {
            [weak self] newSelection in self?.select(newSelection)
        }
    }
    
    private var observation: AnyCancellable? = nil
    
    private func select(_ artifactVM: ArtifactViewModel?)
    {
        artifactVMStack = artifactVM?.getPath() ?? []
    }
    
    var selectionPublisher: any Publisher<ArtifactViewModel, Never>
    
    // MARK: - Manage Whole Stack

    func add(_ artifactVM: ArtifactViewModel)
    {
        remove(artifactVM)

        artifactVMStack.append(artifactVM)
    }

    func remove(_ artifactVM: ArtifactViewModel)
    {
        if let firstIndex = artifactVMStack.firstIndex(of: artifactVM)
        {
            let lastIndex = artifactVMStack.count - 1
            artifactVMStack.removeSubrange(firstIndex ... lastIndex)
        }
    }
    
    @Published private(set) var artifactVMStack = [ArtifactViewModel]()
}

