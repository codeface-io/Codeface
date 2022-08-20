import LSPServiceKit
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
        if ProjectConfigPersister.hasPersistedLastProjectConfig, activeProject == nil
        {
            loadLastActiveProject()
        }
        #endif
    }
    
    // MARK: - Other Elements
    
    let overviewBar = OverviewBar()
    
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
    
    // MARK: - Active Project
    
    func loadNewActiveProject(with config: LSPProjectConfiguration)
    {
        do
        {
            try setAndAnalyzeActiveProject(with: config)
            try ProjectConfigPersister.persist(projectConfig: config)
        }
        catch { log(error) }
    }
    
    func loadLastActiveProject()
    {
        do
        {
            try setAndAnalyzeActiveProject(with: ProjectConfigPersister.loadProjectConfig())
        }
        catch { log(error) }
    }
    
    private func setAndAnalyzeActiveProject(with config: LSPProjectConfiguration) throws
    {
        set(activeProject: try Project(config: config))
        try activeProject?.startAnalysis()
    }
    
    private func set(activeProject: Project)
    {
        selectedArtifact = nil
        
        stopObserving(self.activeProject?.$analysisState)
        
        observe(activeProject.$analysisState).new()
        {
            self.analysisState = $0
        }
        
        self.activeProject = activeProject
        self.analysisState = activeProject.analysisState
    }
    
    @Published var selectedArtifact: ArtifactViewModel?
    @Published private(set) var analysisState: Project.AnalysisState = .stopped
    private(set) var activeProject: Project?
    
    // MARK: - Observer
    
    let receiver = Receiver()
}
