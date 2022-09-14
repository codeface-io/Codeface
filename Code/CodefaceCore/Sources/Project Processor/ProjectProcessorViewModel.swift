import Foundation
import Combine

@MainActor
public class ProjectProcessorViewModel: ObservableObject
{
    public init(activeProcessor: ProjectProcessor) async
    {
        self.activeProcessor = activeProcessor
        self.analysisState = await activeProcessor.state
        self.projectName = activeProcessor.projectLocation.folder.lastPathComponent
        self.stateObservation = await activeProcessor.$state.sink
        {
            self.analysisState = $0
            
            if case .succeeded = $0
            {
                Task
                {
                    self.projectData = await activeProcessor.encodeProjectData()
                }
            }
        }
    }
    
    deinit
    {
        stateObservation?.cancel()
        stateObservation = nil
    }
    
    // MARK: - Search
    
    public func removeSearchFilter()
    {
        updateArtifacts(withSearchTerm: "", allPass: true)
        appliedSearchTerm = nil
        isTypingSearch = false
    }
    
    public func userChanged(searchTerm: String)
    {
        guard isTypingSearch else { return }
        
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
    
    @Published public var isTypingSearch: Bool = false
    @Published public var appliedSearchTerm: String?
    
    // MARK: - Active Analysis
    
    public let projectName: String
    @Published public var projectData: Data? = nil
    
    @Published public var selectedArtifact: ArtifactViewModel? = nil
    
    @Published public private(set) var analysisState: ProjectProcessor.State = .stopped
    private var stateObservation: AnyCancellable?
    
    private let activeProcessor: ProjectProcessor
    
    // MARK: - Other Elements
    
    @Published public var displayMode: DisplayMode = .treeMap
    
    public let pathBar = PathBar()
}
