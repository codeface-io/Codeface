import SwiftUI
import Combine
import SwiftObserver
import SwiftyToolz

@MainActor
class Codeface: SwiftUI.ObservableObject, Observer
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
    
    // MARK: - Active Project
    
    func set(activeProject: Project)
    {
        stopObserving(self.activeProject?.$analysisResult)
        
        observe(activeProject.$analysisResult).new().unwrap()
        {
            $0.rootArtifact.isExpanded = true
            self.artifacts = [$0.rootArtifact]
//            self.objectWillChange.send()
        }
        
        self.activeProject = activeProject
        
        if let rootArtifact = activeProject.analysisResult?.rootArtifact
        {
            rootArtifact.isExpanded = true
            self.artifacts = [rootArtifact]
        }
        else
        {
            self.artifacts = []
        }
        
        do
        {
            try activeProject.startAnalysis()
        }
        catch
        {
            log(error)
        }
    }
    
    @Published var selectedArtifact: CodeArtifact?
    
    @Published private(set) var artifacts = [CodeArtifact]()
    
    private(set) var activeProject: Project?
    
    // MARK: - Observer
    
    let receiver = Receiver()
}

extension CodeArtifact: Hashable
{
    nonisolated static func == (lhs: CodeArtifact, rhs: CodeArtifact) -> Bool
    {
        // TODO: implement true equality instead of identity
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
