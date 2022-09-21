import Foundation
import Combine

@MainActor
public class ProjectProcessorViewModel: ObservableObject
{
    public init(processor: ProjectProcessor) async
    {
        self.activeProcessor = processor
        let currentProcessorState = await processor.state
        processorState = currentProcessorState
        codebaseName = currentProcessorState.codebaseName
        
        stateObservation = await processor.$state.sink
        {
            newState in
            
            /// TODO: the compiler does not warn that we must – let alone enforce that we do – jump to our own actor (in this case the MainActor). First of all: Why the fuck not? The sink closure often runs on other actors than MainActor. Second: How can we observe across actors more easily? (If self was its own actor) We can use `.receive(on: DispatchQueue.main).sink` to receive the update on the main **queue**, but how can we receive it on any **actor**, in particular on actor `self`?
            
            Task
            {
                await MainActor.run
                {
                    self.processorDidUpdate(toNewState: newState)
                }
            }
        }
    }
    
    deinit
    {
        stateObservation?.cancel()
        stateObservation = nil
    }
    
    // MARK: - Search
    
    public func removeSearchFilter()
    {
        updateArtifacts(withSearchTerm: "", allPass: true)
        appliedSearchTerm = nil
        isTypingSearch = false
    }
    
    public func userChanged(searchTerm: String)
    {
        guard isTypingSearch else { return }
        
        updateArtifacts(withSearchTerm: searchTerm, allPass: false)
        
        appliedSearchTerm = searchTerm
    }
    
    private func updateArtifacts(withSearchTerm searchTerm: String,
                                 allPass: Bool)
    {
        if case .didVisualizeCodebaseArchitecture(_, let rootViewModel) = processorState
        {
            rootViewModel.updateSearchResults(withSearchTerm: searchTerm)
            rootViewModel.updateSearchFilter(allPass: allPass)
        }
    }
    
    @Published public var isTypingSearch: Bool = false
    @Published public var appliedSearchTerm: String?
    
    // MARK: - Active Analysis
    
    public var codebaseDisplayName: String { codebaseName ?? "Untitled Codebase" }
    private var codebaseName: String?
    
    @Published public var selectedArtifact: ArtifactViewModel? = nil
    {
        didSet
        {
            guard oldValue !== selectedArtifact else { return }
            selectedArtifact?.ignoredFilterOnLastLayout = nil
            selectedArtifact?.lastScopeContentSize = nil
            pathBar.select(selectedArtifact)
        }
    }
    
    private func processorDidUpdate(toNewState newState: ProjectProcessor.State)
    {
        if codebaseName == nil, let newCodebaseName = newState.codebaseName
        {
            codebaseName = newCodebaseName
        }
        
        processorState = newState
    }
    
    @Published public private(set) var processorState: ProjectProcessor.State
    private var stateObservation: AnyCancellable?
    
    private let activeProcessor: ProjectProcessor
    
    // MARK: - Other Elements
    
    func switchDisplayMode()
    {
        switch displayMode
        {
        case .code: displayMode = .treeMap
        case .treeMap: displayMode = .code
        }
    }
    
    @Published public var displayMode: DisplayMode = .treeMap
    
    public let pathBar = PathBar()
}

private extension ProjectProcessor.State
{
    var codebaseName: String?
    {
        switch self
        {
        case .didLocateCodebase(let location): return location.folder.lastPathComponent
        case .didRetrieveCodebase(let codebase): return codebase.name
        case .didVisualizeCodebaseArchitecture(let codebase, _): return codebase.name
        default: return nil
        }
    }
}

