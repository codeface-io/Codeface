import LSPServiceKit
import Foundation
import Combine
import SwiftyToolz

@MainActor
public class ProjectAnalysisViewModel: ObservableObject
{
    public init(activeAnalysis: ProjectAnalysis? = nil)
    {
        self.activeAnalysis = activeAnalysis
    }
    
    // MARK: - Search
    
    public func removeSearchFilter()
    {
        updateArtifacts(withSearchTerm: "", allPass: true)
        appliedSearchTerm = nil
        isSearching = false
    }
    
    public func userChanged(searchTerm: String)
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
    
    public func beginSearch()
    {
        isSearching = true
    }
    
    public func submitSearch()
    {
        isSearching = false
    }
    
    @Published public var isSearching: Bool = false
    @Published public var appliedSearchTerm: String?
    
    // MARK: - Active Analysis
    
    public func loadLastProjectIfNoneIsActive()
    {
        if ProjectDescriptionPersister.hasPersistedLastProject, activeAnalysis == nil
        {
            loadLastActiveProject()
        }
    }
    
    public func loadLastActiveProject()
    {
        do
        {
            try setAndStartActiveAnalysis(with: ProjectDescriptionPersister.loadProjectConfig())
        }
        catch { log(error) }
    }
    
    public func loadNewActiveAnalysis(for project: LSPProjectDescription)
    {
        do
        {
            try setAndStartActiveAnalysis(with: project)
            try ProjectDescriptionPersister.persist(project)
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
        self.selectedArtifact = nil
        
        self.activeAnalysis = activeAnalysis
        
        self.analysisState = activeAnalysis.state
        self.stateObservation?.cancel()
        self.stateObservation = activeAnalysis.$state.sink { self.analysisState = $0 }
    }
    
    @Published public var selectedArtifact: ArtifactViewModel?
    
    public private(set) var activeAnalysis: ProjectAnalysis?
    
    @Published public private(set) var analysisState: ProjectAnalysis.State = .stopped
    private var stateObservation: AnyCancellable?
    
    // MARK: - Other Elements
    
    @Published public var displayMode: DisplayMode = .treeMap
    
    public let pathBar = PathBar()
}
