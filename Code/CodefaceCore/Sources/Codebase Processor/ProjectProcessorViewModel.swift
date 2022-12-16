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
    
    public func userWantsToFindAndFilter()
    {
        if !searchVM.searchBarIsShown
        {
            searchVM.searchBarIsShown = true
        }
        else
        {
            searchVM.fieldIsFocused = true
        }
    }
    
    public func clearSearchField()
    {
        searchVM.searchTerm = ""
        updateSearchFilter()
    }
    
    public func userChanged(fieldIsFocused: Bool)
    {
        searchVM.fieldIsFocused = fieldIsFocused
        
        if fieldIsFocused
        {
            searchFieldObtainedFocus()
            
            if !searchVM.searchTerm.isEmpty {
                searchVM.submitButtonIsShown = true
            }
        }
        else if searchVM.submitButtonIsShown
        {
            submit()
        }
    }
    
    public func searchFieldObtainedFocus()
    {
        searchVM.isTypingSearch = true
    }
    
    public func write(searchTerm: String)
    {
        guard searchVM.searchTerm != searchTerm else { return }
        
        searchVM.searchTerm = searchTerm
        userChangedSearchTerm()
        searchVM.submitButtonIsShown = !searchVM.searchTerm.isEmpty
    }
    
    public func userChangedSearchTerm()
    {
        searchVM.isTypingSearch = true
        updateSearchFilter()
    }
    
    public func submitSearchTerm()
    {
        searchVM.submitButtonIsShown = false
        submit()
        searchVM.fieldIsFocused = false
    }
    
    public func submit()
    {
        searchVM.isTypingSearch = false
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

public struct SearchVM
{
    public var searchBarIsShown = false
    {
        didSet
        {
            guard oldValue != searchBarIsShown else { return }
            fieldIsFocused = searchBarIsShown
        }
    }
    
    public var fieldIsFocused = false
    public var submitButtonIsShown = false
    public fileprivate(set) var searchTerm = ""
    public var isTypingSearch = false
    
    public static let visibilityToggleAnimationDuration: Double = 0.15
}
