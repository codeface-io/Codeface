import Foundation
import Combine

@MainActor
public class ProjectProcessorViewModel: ObservableObject
{
    public init(activeProcessor: ProjectProcessor) async
    {
        self.activeProcessor = activeProcessor
        processorState = await activeProcessor.state
        projectName = activeProcessor.projectName
        
        stateObservation = await activeProcessor.$state.sink
        {
            newState in
            
            /// TODO: the compiler does not warn that we must – let alone enforce that we do – jump to our own actor (in this case the MainActor) or do it asynchronously when setting `self.processorState`. First of all: Why the fuck not? It's obviously mutating data across actors since the sink closure runs on actor `ProjectProcessor`. Second: How can we observe across actors more easily? We could use `.receive(on: DispatchQueue.main).sink` to receive the update on the main **queue**, but how can we receive it on any **actor**, in particular on actor `self`?
            
            Task { await MainActor.run { self.processorState = newState } }
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
        if case .didVisualizeProjectArchitecture(_, let rootViewModel) = processorState
        {
            rootViewModel.updateSearchResults(withSearchTerm: searchTerm)
            rootViewModel.updateSearchFilter(allPass: allPass)
        }
    }
    
    @Published public var isTypingSearch: Bool = false
    @Published public var appliedSearchTerm: String?
    
    // MARK: - Active Analysis
    
    public let projectName: String
    
    @Published public var selectedArtifact: ArtifactViewModel? = nil
    
    @Published public private(set) var processorState: ProjectProcessor.State
    private var stateObservation: AnyCancellable?
    
    private let activeProcessor: ProjectProcessor
    
    // MARK: - Other Elements
    
    @Published public var displayMode: DisplayMode = .treeMap
    
    public let pathBar = PathBar()
}
