import Combine

@MainActor
public class ProjectAnalysisViewModel: ObservableObject
{
    public init(activeAnalysis: ProjectAnalysis)
    {
        self.activeAnalysis = activeAnalysis
        self.analysisState = activeAnalysis.state
        self.stateObservation = activeAnalysis.$state.sink { self.analysisState = $0 }
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
        if case .succeeded(let rootViewModel) = analysisState
        {
            rootViewModel.updateSearchResults(withSearchTerm: searchTerm)
            rootViewModel.updateSearchFilter(allPass: allPass)
        }
    }
    
    @Published public var isTypingSearch: Bool = false
    @Published public var appliedSearchTerm: String?
    
    // MARK: - Active Analysis
    
    @Published public var selectedArtifact: ArtifactViewModel? = nil
    
    public private(set) var activeAnalysis: ProjectAnalysis
    
    @Published public private(set) var analysisState: ProjectAnalysis.State = .stopped
    private var stateObservation: AnyCancellable?
    
    // MARK: - Other Elements
    
    @Published public var displayMode: DisplayMode = .treeMap
    
    public let pathBar = PathBar()
}
