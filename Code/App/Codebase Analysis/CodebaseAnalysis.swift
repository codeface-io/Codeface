import Combine

@MainActor
class CodebaseAnalysis: ObservableObject
{
    init(rootArtifact: ArtifactViewModel)
    {
        self.rootArtifact = rootArtifact
        self.selectedArtifact = rootArtifact
    }
    
    // MARK: - Search
    
    func startTypingSearchTerm()
    {
        search.barIsShown = true
        set(fieldIsFocused: true)
    }
    
    func toggleSearchBar()
    {
        search.barIsShown.toggle()
        set(fieldIsFocused: search.barIsShown)
    }
    
    func hideSearchBar()
    {
        set(fieldIsFocused: false)
        search.barIsShown = false
    }
    
    func set(fieldIsFocused: Bool)
    {
        guard search.fieldIsFocused != fieldIsFocused else { return }
        search.fieldIsFocused = fieldIsFocused
        if !fieldIsFocused { submitSearchTerm() }
    }
    
    func set(searchTerm: String)
    {
        guard search.term != searchTerm else { return }
        search.term = searchTerm
        updateSearchFilter()
    }
    
    func submitSearchTerm()
    {
        search.fieldIsFocused = false
        updateSearchFilter()
    }
    
    private func updateSearchFilter()
    {
        // TODO: rather "clear search results" when term is empty
        rootArtifact.updateSearchResults(withSearchTerm: search.term)
            
        rootArtifact.updateSearchFilter(allPass: search.term.isEmpty)
    }
    
    @Published var search = Search()
    
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
