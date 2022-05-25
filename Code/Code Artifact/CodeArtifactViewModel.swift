import SwiftUI
import Combine
import SwiftObserver
import SwiftyToolz

@MainActor
class CodeArtifactViewModel: SwiftUI.ObservableObject, Observer
{
    // MARK: - Initialize
    
    init()
    {
        if let rootArtifact = Project.shared?.analysisResult?.rootArtifact
        {
            rootArtifact.isExpanded = true
            self.artifacts = [rootArtifact]
        }
        
        observe(Project.messenger)
        {
            switch $0
            {
            case .didCompleteAnalysis(let analysisResult):
                analysisResult.rootArtifact.isExpanded = true
                self.artifacts = [analysisResult.rootArtifact]
            }
        }
    }
    
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
    
    // MARK: - Basics
    
    @Published var selectedArtifact: CodeArtifact?
    
    @Published var artifacts = [CodeArtifact]()
    
    let receiver = Receiver()
}

extension CodeArtifact: Hashable
{
    static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
