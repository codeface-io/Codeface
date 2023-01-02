import FoundationToolz
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
        Task // to enter an async context
        {
            // get codebase
            guard let codebase = await retrieveCodebase() else { return }

            // generate architecture
            let codebaseArchitecture = await generateArchitecture(from: codebase)
            
            // calculate metrics
            state = .visualizingCodebaseArchitecture(.calculateMetrics)
            
            await BackgroundActor.run
            {
                codebaseArchitecture.calculateSizeMetricsRecursively()
                codebaseArchitecture.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
                codebaseArchitecture.calculateCycleMetricsRecursively()
            }
            
            // sort artifacts
            state = .visualizingCodebaseArchitecture(.sortCodeArtifacts)
            
            await BackgroundActor.run
            {
                codebaseArchitecture.traverseDepthFirst { $0.sort() }
            }
            
            // create view model
            // TODO: to put view model creation onto the background actor, we have to split it in two: 1) a dumb view state object that runs on the main actor and 2) a view model object that does the computations and runs on the background actor and is observed by the state object. however: even for a large codebase (sourcekit-lsp) creating the view model and adding its dependencies each only take 10 mili seconds, so offloading this to the background isn't super essential.
            state = .visualizingCodebaseArchitecture(.createViewModels)
            
            var stopWatch = StopWatch()
            let architectureViewModel = ArtifactViewModel(folderArtifact: codebaseArchitecture,
                                                          isPackage: codebase.looksLikeAPackage)
            stopWatch.measure("Creating View Model")
            
            stopWatch.restart()
            architectureViewModel.addDependencies()
            stopWatch.measure("Adding Dependencies To View Model")
            
            state = .didVisualizeCodebaseArchitecture(codebase, architectureViewModel)
        }
    }
    
    private func retrieveCodebase() async -> CodeFolder?
    {
        switch state
        {
        case .didLocateCodebase(let codebaseLocation):
            state = .retrievingCodebase(.readFolder)
            guard let codebaseWithoutSymbols = await readCodebaseFolder(from: codebaseLocation) else
            {
                return nil
            }
            
            do
            {
                state = .retrievingCodebase(.connectToLSPServer)
                let server = try await LSP.ServerManager.shared.initializeServer(for: codebaseLocation)
                
                state = .retrievingCodebase(.retrieveSymbolsAndRefs)
                
                let codebase = try await ProcessingSteps.retrieveSymbolsAndReferences(for: codebaseWithoutSymbols,
                                                                                      from: server,
                                                                                      codebaseRootFolder: codebaseLocation.folder)
                
                state = .didRetrieveCodebase(codebase)
                return codebase
            }
            catch
            {
                log(warning: "Cannot talk to LSP server: " + error.readable.message)
                LSP.ServerManager.shared.serverIsWorking = false
                
                state = .didRetrieveCodebase(codebaseWithoutSymbols)
                return codebaseWithoutSymbols
            }
            
        case .didRetrieveCodebase(let codebase):
            return codebase
            
        case .didVisualizeCodebaseArchitecture(let codebase, _):
            return codebase
            
        default:
            log(error: "Processor can't start processing as it is in state \(state)")
            return nil
        }
    }
    
    private func readCodebaseFolder(from codebaseLocation: LSP.CodebaseLocation) async -> CodeFolder?
    {
        do
        {
            return try await ProcessingSteps.readFolder(from: codebaseLocation)
        }
        catch
        {
            log(error.readable.message)
            state = .failed(error.readable.message)
            return nil
        }
    }
    
    private func generateArchitecture(from codebase: CodeFolder) async -> CodeFolderArtifact
    {
        // generate basic hierarchy
        state = .visualizingCodebaseArchitecture(.generateArchitecture)
        let architecture = await ProcessingSteps.generateArchitecture(from: codebase)
        
        // add dependencies between sibling symbols
        state = .visualizingCodebaseArchitecture(.addSiblingSymbolDependencies)
        await ProcessingSteps.addSymbolDependencies(in: architecture)
        
        // add dependencies on higher levels (across scopes)
        state = .visualizingCodebaseArchitecture(.calculateHigherLevelDependencies)
        await ProcessingSteps.addHigherLevelDependencies(in: architecture)
        
        return architecture
    }
    
    // MARK: - State
    
    public var codebaseDisplayName: String { state.codebaseName ?? "Untitled Codebase" }
    
    @Published public var state = ProcessorState.empty
}

@BackgroundActor
enum ProcessingSteps // some temporary namespace to offload the actual processing from the main actor
{
    static func readFolder(from location: LSP.CodebaseLocation) throws -> CodeFolder?
    {
        try location.folder.mapSecurityScoped
        {
            guard let codeFolder = try CodeFolder($0, codeFileEndings: location.codeFileEndings) else
            {
                throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(location.codeFileEndings)"
            }
            
            return codeFolder
        }
    }
    
    static func retrieveSymbolsAndReferences(for codebase: CodeFolder,
                                             from server: LSP.Server,
                                             codebaseRootFolder: URL) async throws -> CodeFolder
    {
        try await codebase.retrieveSymbolsAndReferences(from: server,
                                                        codebaseRootFolder: codebaseRootFolder)
    }
    
    static func generateArchitecture(from folder: CodeFolder) -> CodeFolderArtifact
    {
        CodeSymbolArtifact.symbolHash.removeAll()
        return CodeFolderArtifact(codeFolder: folder, scope: nil)
    }
    
    static func addSymbolDependencies(in architecture: CodeFolderArtifact)
    {
        architecture.addSymbolDependencies()
    }
    
    static func addHigherLevelDependencies(in architecture: CodeFolderArtifact)
    {
        architecture.addCrossScopeDependencies()
    }
}
