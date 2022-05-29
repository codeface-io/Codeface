import Combine
import SwiftObserver
import SwiftyToolz

@MainActor
class Codeface: Combine.ObservableObject, Observer
{
    // MARK: - Search
    
    func removeSearchFilter()
    {
        updateArtifacts(withSearchTerm: "", allPass: true)
        appliedSearchTerm = nil
        isSearching = false
    }
    
    func userChanged(searchTerm: String)
    {
        guard isSearching else { return }
        
        updateArtifacts(withSearchTerm: searchTerm, allPass: false)
        
        appliedSearchTerm = searchTerm
    }
    
    private func updateArtifacts(withSearchTerm searchTerm: String,
                                 allPass: Bool)
    {
        for artifact in artifacts
        {
            artifact.updateSearchResults(withSearchTerm: searchTerm)
            artifact.updateSearchFilter(allPass: allPass)
        }
    }
    
    func beginSearch()
    {
        isSearching = true
    }
    
    func submitSearch()
    {
        isSearching = false
    }
    
    @Published var isSearching: Bool = false
    @Published var appliedSearchTerm: String?
    
    // MARK: - Display Mode
    
    @Published var displayMode: DisplayMode = .treeMap
    
    // MARK: - Active Project
    
    func setAndAnalyzeActiveProject(with config: Project.Configuration) throws
    {
        set(activeProject: try Project(config: config))
        try activeProject?.startAnalysis()
    }
    
    private func set(activeProject: Project)
    {
        stopObserving(self.activeProject?.$rootArtifact)
        
        observe(activeProject.$rootArtifact).new().unwrap()
        {
            $0.isExpanded = true
            self.artifacts = [$0]
        }
        
        self.activeProject = activeProject
        
        if let rootArtifact = activeProject.rootArtifact
        {
            rootArtifact.isExpanded = true
            self.artifacts = [rootArtifact]
        }
        else
        {
            self.artifacts = []
        }
    }
    
    @Published var selectedArtifact: CodeArtifact?
    @Published private(set) var artifacts = [CodeArtifact]()
    private(set) var activeProject: Project?
    
    // MARK: - Observer
    
    let receiver = Receiver()
}
