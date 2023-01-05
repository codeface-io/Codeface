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
    
    public func startTypingSearchTerm()
    {
        search.barIsShown = true
        set(fieldIsFocused: true)
    }
    
    public func toggleSearchBar()
    {
        search.barIsShown.toggle()
        set(fieldIsFocused: search.barIsShown)
    }
    
    public func hideSearchBar()
    {
        set(fieldIsFocused: false)
        search.barIsShown = false
    }
    
    public func set(fieldIsFocused: Bool)
    {
        guard search.fieldIsFocused != fieldIsFocused else { return }
        search.fieldIsFocused = fieldIsFocused
        if !fieldIsFocused { submitSearchTerm() }
    }
    
    public func set(searchTerm: String)
    {
        guard search.term != searchTerm else { return }
        search.term = searchTerm
        updateSearchFilter()
    }
    
    public func submitSearchTerm()
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
    
    @Published public var search = Search()
    
    // MARK: - Path Bar
    
    public private(set) lazy var pathBar: PathBar =
    {
        PathBar(selectionPublisher: $selectedArtifact)
    }()

    // MARK: - Artifact View Models
    
    let rootArtifact: ArtifactViewModel
    @Published var selectedArtifact: ArtifactViewModel
    
    // MARK: - Display Options
    
    @Published public var showsLeftSidebar: Bool = true
    @Published public var showsRightSidebar: Bool = false
    @Published public var showLoC: Bool = false
    
    public func switchDisplayMode()
    {
        switch displayMode
        {
        case .code: displayMode = .treeMap
        case .treeMap: displayMode = .code
        }
    }
    
    @Published public var displayMode: DisplayMode = .treeMap
}
