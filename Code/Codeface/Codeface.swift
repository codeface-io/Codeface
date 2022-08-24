import LSPServiceKit
import CodefaceCore
import Foundation
import Combine
import SwiftObserver
import SwiftyToolz

@MainActor
class Codeface: Combine.ObservableObject, Observer
{
    // MARK: - Life Cycle
    
    func didBecomeActive()
    {
        loadLastProjectInDebugBuilds()
    }
    
    private func loadLastProjectInDebugBuilds()
    {
        #if DEBUG
        if ProjectConfigPersister.hasPersistedLastProjectConfig, activeAnalysis == nil
        {
            loadLastActiveProject()
        }
        #endif
    }
    
    // MARK: - Other Elements
    
    let pathBar = PathBar()
    
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
        if case .succeeded(let rootViewModel) = analysisState
        {
            rootViewModel.updateSearchResults(withSearchTerm: searchTerm)
            rootViewModel.updateSearchFilter(allPass: allPass)
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
    
    // MARK: - Active Abalysis
    
    func loadNewActiveProject(with config: LSPProjectDescription)
    {
        do
        {
            try setAndStartActiveAnalysis(with: config)
            try ProjectConfigPersister.persist(projectConfig: config)
        }
        catch { log(error) }
    }
    
    func loadLastActiveProject()
    {
        do
        {
            try setAndStartActiveAnalysis(with: ProjectConfigPersister.loadProjectConfig())
        }
        catch { log(error) }
    }
    
    private func setAndStartActiveAnalysis(with project: LSPProjectDescription) throws
    {
        set(activeAnalysis: try ProjectAnalysis(project: project))
        try activeAnalysis?.start()
    }
    
    private func set(activeAnalysis: ProjectAnalysis)
    {
        selectedArtifact = nil
        
        stopObserving(self.activeAnalysis?.$state)
        
        observe(activeAnalysis.$state).new()
        {
            self.analysisState = $0
        }
        
        self.activeAnalysis = activeAnalysis
        self.analysisState = activeAnalysis.state
    }
    
    @Published var selectedArtifact: ArtifactViewModel?
    @Published private(set) var analysisState: ProjectAnalysis.State = .stopped
    private(set) var activeAnalysis: ProjectAnalysis?
    
    // MARK: - Observer
    
    let receiver = Receiver()
}
