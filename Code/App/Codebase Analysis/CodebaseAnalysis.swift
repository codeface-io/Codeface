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
    
    func set(searchBarIsVisible: Bool)
    {
        search.barIsShown = searchBarIsVisible
    }
    
    func set(fieldIsFocused: Bool)
    {
        guard search.fieldIsFocused != fieldIsFocused else { return }
        search.fieldIsFocused = fieldIsFocused
        if !fieldIsFocused { updateSearchFilter() }
        selectedArtifact.updateLayout(applySearchFilter: !fieldIsFocused)
    }
    
    func set(searchTerm: String)
    {
        guard search.term != searchTerm else { return }
        search.term = searchTerm // this fires since search is Published -> only for connecting to search text field UI ...
        updateSearchFilter() // update the filter synchronously, updates `passesSearchFilter` which is Published ...
        
        let didClearSearchTermViaButton = searchTerm.isEmpty && !search.fieldIsFocused
        
        if didClearSearchTermViaButton
        {
            selectedArtifact.updateLayout(applySearchFilter: false)
        }
    }
    
    private func updateSearchFilter()
    {
        if GlobalSettings.shared.updateSearchTermGlobally
        {
            // TODO: rather "clear search results" when term is empty
            rootArtifact.updateSearchResults(withSearchTerm: search.term)
            
            rootArtifact.updateSearchFilter(allPass: search.term.isEmpty)
        }
        else
        {
            // TODO: rather "clear search results" when term is empty
            selectedArtifact.updateSearchResults(withSearchTerm: search.term)
            
            selectedArtifact.updateSearchFilter(allPass: search.term.isEmpty)
        }
    }
    
    @Published private(set) var search = Search()
    
    // MARK: - Path Bar
    
    private(set) lazy var pathBar: PathBar =
    {
        PathBar(selectionPublisher: $selectedArtifact)
    }()

    // MARK: - Artifact View Models
    
    let rootArtifact: ArtifactViewModel
    
    // ⚠️ observers of CodebaseAnalysis will be notified when the selected artifact is replaced, but not when any of its properties change, even though ArtifactViewModel is itself an observable class
    @Published var selectedArtifact: ArtifactViewModel
    
    // MARK: - Display Mode
    
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
