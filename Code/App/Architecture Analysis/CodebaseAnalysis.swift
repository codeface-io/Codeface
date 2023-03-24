import Combine

@MainActor
class ArchitectureAnalysis: ObservableObject
{
    init(rootArtifact: ArtifactViewModel)
    {
        self.rootArtifact = rootArtifact
        self.selectedArtifact = rootArtifact
    }
    
    // MARK: - Search
    
    func set(searchBarIsVisible: Bool)
    {
        search.barIsShown = searchBarIsVisible
    }
    
    func set(fieldIsFocused: Bool)
    {
        guard search.fieldIsFocused != fieldIsFocused else { return }
        search.fieldIsFocused = fieldIsFocused
        if !fieldIsFocused { updateSearchFilter() }
        selectedArtifact.updateLayout(ignoreSearchFilter: fieldIsFocused)
    }
    
    func set(searchTerm: String)
    {
        guard search.term != searchTerm else { return }
        search.term = searchTerm
        updateSearchFilter()
        
        let didClearSearchTermViaButton = searchTerm.isEmpty && !search.fieldIsFocused
        
        if didClearSearchTermViaButton
        {
            selectedArtifact.updateLayout(ignoreSearchFilter: true)
        }
    }
    
    private func updateSearchFilter()
    {
        // TODO: rather "clear search results" when term is empty
        rootArtifact.updateSearchResults(withSearchTerm: search.term)
            
        rootArtifact.updateSearchFilter(allPass: search.term.isEmpty)
    }
    
    @Published private(set) var search = Search()
    
    // MARK: - Path Bar
    
    private(set) lazy var pathBar: PathBar =
    {
        PathBar(selectionPublisher: $selectedArtifact)
    }()

    // MARK: - Artifact View Models
    
    let rootArtifact: ArtifactViewModel
    @Published var selectedArtifact: ArtifactViewModel
    
    // MARK: - Display Options
    
    @Published var showsLeftSidebar: Bool = true
    @Published var showsRightSidebar: Bool = false
    @Published var showLoC: Bool = false
    @Published var showSubscriptionPanel = false
    
    func switchDisplayMode()
    {
        switch displayMode
        {
        case .code: displayMode = .treeMap
        case .treeMap: displayMode = .code
        }
    }
    
    @Published var displayMode: DisplayMode = .treeMap
}
