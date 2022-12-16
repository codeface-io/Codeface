import Foundation
import Combine

@MainActor
public class ProjectProcessorViewModel: ObservableObject
{
    public init(processor: ProjectProcessor) async
    {
        self.activeProcessor = processor
        let currentProcessorState = await processor.state
        processorState = currentProcessorState
        codebaseName = currentProcessorState.codebaseName
        
        stateObservation = await processor.$state.sink
        {
            newState in
            
            /// TODO: the compiler does not warn that we must – let alone enforce that we do – jump to our own actor (in this case the MainActor). First of all: Why the fuck not? The sink closure often runs on other actors than MainActor. Second: How can we observe across actors more easily? (If self was its own actor) We can use `.receive(on: DispatchQueue.main).sink` to receive the update on the main **queue**, but how can we receive it on any **actor**, in particular on actor `self`?
            
            Task
            {
                await MainActor.run
                {
                    self.processorDidUpdate(toNewState: newState)
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
    
    public func startTypingSearchTerm()
    {
        searchVM.searchBarIsShown = true
        set(fieldIsFocused: true)
    }
    
    public func toggleSearchBar()
    {
        if searchVM.searchBarIsShown { set(fieldIsFocused: false) }
        searchVM.searchBarIsShown.toggle()
    }
    
    public func hideSearchBar()
    {
        set(fieldIsFocused: false)
        searchVM.searchBarIsShown = false
    }
    
    public func set(fieldIsFocused: Bool)
    {
        guard searchVM.fieldIsFocused != fieldIsFocused else { return }
        searchVM.fieldIsFocused = fieldIsFocused
        if !fieldIsFocused { submitSearchTerm() }
    }
    
    public func set(searchTerm: String)
    {
        guard searchVM.searchTerm != searchTerm else { return }
        searchVM.searchTerm = searchTerm
        updateSearchFilter()
    }
    
    public func submitSearchTerm()
    {
        searchVM.fieldIsFocused = false
        updateSearchFilter()
    }
    
    private func updateSearchFilter()
    {
        if case .didVisualizeCodebaseArchitecture(_, let rootViewModel) = processorState
        {
            // TODO: rather "clear search results" when term is empty
            rootViewModel.updateSearchResults(withSearchTerm: searchVM.searchTerm)
            
            rootViewModel.updateSearchFilter(allPass: searchVM.searchTerm.isEmpty)
        }
    }
    
    @Published public var searchVM = SearchVM()
    
    // MARK: - Active Analysis
    
    public var codebaseDisplayName: String { codebaseName ?? "Untitled Codebase" }
    private var codebaseName: String?
    
    private func processorDidUpdate(toNewState newState: ProjectProcessor.State)
    {
        if codebaseName == nil, let newCodebaseName = newState.codebaseName
        {
            codebaseName = newCodebaseName
        }
        
        processorState = newState
    }
    
    @Published public private(set) var processorState: ProjectProcessor.State
    private var stateObservation: AnyCancellable?
    
    private let activeProcessor: ProjectProcessor
    
    // MARK: - Other Elements
    
    func switchDisplayMode()
    {
        switch displayMode
        {
        case .code: displayMode = .treeMap
        case .treeMap: displayMode = .code
        }
    }
    
    @Published public var displayMode: DisplayMode = .treeMap
    
    public let pathBar = PathBar()
}

private extension ProjectProcessor.State
{
    var codebaseName: String?
    {
        switch self
        {
        case .didLocateCodebase(let location): return location.folder.lastPathComponent
        case .didRetrieveCodebase(let codebase): return codebase.name
        case .didVisualizeCodebaseArchitecture(let codebase, _): return codebase.name
        default: return nil
        }
    }
}

@MainActor
public struct SearchVM
{
    public var searchBarIsShown = false
    
    public var fieldIsFocused = false
    {
        didSet
        {
            print("field is focused was set to \(fieldIsFocused)")
        }
    }
    
    
    public var searchTerm = ""
    
    public static let visibilityToggleAnimationDuration: Double = 0.15
}
