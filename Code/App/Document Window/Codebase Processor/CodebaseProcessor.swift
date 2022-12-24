import Foundation
import Combine
import CodefaceCore
import SwiftLSP
import SwiftyToolz

@MainActor
public class CodebaseProcessor: ObservableObject
{
    // MARK: - Path Bar
    
    public let pathBar = PathBar()
    
    // MARK: - Search
    
    public func startTypingSearchTerm()
    {
        searchVM.barIsShown = true
        set(fieldIsFocused: true)
    }
    
    public func toggleSearchBar()
    {
        searchVM.barIsShown.toggle()   
        set(fieldIsFocused: searchVM.barIsShown)
    }
    
    public func hideSearchBar()
    {
        set(fieldIsFocused: false)
        searchVM.barIsShown = false
    }
    
    public func set(fieldIsFocused: Bool)
    {
        guard searchVM.fieldIsFocused != fieldIsFocused else { return }
        searchVM.fieldIsFocused = fieldIsFocused
        if !fieldIsFocused { submitSearchTerm() }
    }
    
    public func set(searchTerm: String)
    {
        guard searchVM.term != searchTerm else { return }
        searchVM.term = searchTerm
        updateSearchFilter()
    }
    
    public func submitSearchTerm()
    {
        searchVM.fieldIsFocused = false
        updateSearchFilter()
    }
    
    private func updateSearchFilter()
    {
        if case .didVisualizeCodebaseArchitecture(_, let rootViewModel) = state
        {
            // TODO: rather "clear search results" when term is empty
            rootViewModel.updateSearchResults(withSearchTerm: searchVM.term)
            
            rootViewModel.updateSearchFilter(allPass: searchVM.term.isEmpty)
        }
    }
    
    @Published public var searchVM = SearchVM()
    
    // MARK: - Run Processing
    
    public func run()
    {
        Task(priority: .background)
        {
            log("gonna retrieve codebase")
            
            // get codebase
            guard let codebase = await retrieveCodebase() else { return }
            
            log("did retrieve codebase")
            
            // generate architecture
            let codebaseArchitecture = generateArchitecture(from: codebase)
            
            log("did generate architecture codebase")
            
            // analyze architecture
            state = .visualizingCodebaseArchitecture(.calculateMetrics)
            codebaseArchitecture.calculateSizeMetricsRecursively()
            codebaseArchitecture.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
            codebaseArchitecture.calculateCycleMetricsRecursively()
            
            // visualize architecture
            state = .visualizingCodebaseArchitecture(.sortCodeArtifacts)
            codebaseArchitecture.traverseDepthFirst { $0.sort() }
            
            state = .visualizingCodebaseArchitecture(.createViewModels)
            let architectureViewModel = ArtifactViewModel(folderArtifact: codebaseArchitecture,
                                                          isPackage: codebase.looksLikeAPackage)
            architectureViewModel.addDependencies()
            
            state = .didVisualizeCodebaseArchitecture(codebase, architectureViewModel)
        }
    }
    
    private func retrieveCodebase() async -> CodeFolder?
    {
        switch state
        {
        case .didLocateCodebase(let codebaseLocation):
            log("processor state: did locate codebase")
            
            state = .retrievingCodebase(.readFolder)
            guard let codebase = readCodebaseFolder(from: codebaseLocation) else { return nil }
            
            log("did read codebase folder")
            
            do
            {
                state = .retrievingCodebase(.connectToLSPServer)
                let server = try await LSP.ServerManager.shared.initializeServer(for: codebaseLocation)
                
                log("did connect to server")
                
                state = .retrievingCodebase(.retrieveSymbols)
//                var stopWatch = StopWatch()
                try await codebase.retrieveSymbolData(from: server,
                                                      codebaseRootFolder: codebaseLocation.folder)
//                stopWatch.measure("Retrieving Symbols")
                
                state = .retrievingCodebase(.retrieveReferences)
//                stopWatch.restart()
                try await codebase.retrieveSymbolReferences(from: server,
                                                            codebaseRootFolder: codebaseLocation.folder)
//                stopWatch.measure("Retrieving Symbol References")
            }
            catch
            {
                log(warning: "Cannot talk to LSP server: " + error.readable.message)
                LSP.ServerManager.shared.serverIsWorking = false
            }
            
            state = .didRetrieveCodebase(codebase)
            
            return codebase
        case .didRetrieveCodebase(let codebase):
            return codebase
        case .didVisualizeCodebaseArchitecture(let codebase, _):
            return codebase
        default:
            log(error: "Processor can't start processing as it is in state \(state)")
            return nil
        }
    }
    
    private func readCodebaseFolder(from codebaseLocation: LSP.CodebaseLocation) -> CodeFolder?
    {
        do
        {
            return try codebaseLocation.folder.mapSecurityScoped
            {
                guard let codeFolder = try CodeFolder($0, codeFileEndings: codebaseLocation.codeFileEndings) else
                {
                    throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(codebaseLocation.codeFileEndings)"
                }
                
                return codeFolder
            }
        }
        catch
        {
            log(error.readable.message)
            state = .failed(error.readable.message)
            return nil
        }
    }
    
    private func generateArchitecture(from codebase: CodeFolder) -> CodeFolderArtifact
    {
        // generate basic hierarchy
        state = .visualizingCodebaseArchitecture(.generateArchitecture)
        var symbolDataHash = [CodeSymbolArtifact: CodeSymbolData]()
        let codebaseArchitecture = CodeFolderArtifact(codeFolder: codebase,
                                                      scope: nil,
                                                      symbolDataHash: &symbolDataHash)
        
        // add dependencies between sibling symbols
        state = .visualizingCodebaseArchitecture(.addSiblingSymbolDependencies)
        codebaseArchitecture.addSymbolDependencies(symbolDataHash: symbolDataHash)
        symbolDataHash.removeAll()
        
        // add dependencies on higher levels (across scopes)
        state = .visualizingCodebaseArchitecture(.calculateHigherLevelDependencies)
        codebaseArchitecture.addCrossScopeDependencies()
        
        return codebaseArchitecture
    }
    
    // MARK: - State
    
    public var codebaseDisplayName: String { state.codebaseName ?? "Untitled Codebase" }
    
    @Published public var state = ProcessorState.empty
}
