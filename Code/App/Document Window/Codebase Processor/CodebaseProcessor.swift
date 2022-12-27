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
            state = .retrievingCodebase(.readFolder)
            guard let codebaseWithoutSymbols = readCodebaseFolder(from: codebaseLocation) else
            {
                return nil
            }
            
            do
            {
                state = .retrievingCodebase(.connectToLSPServer)
                let server = try await LSP.ServerManager.shared.initializeServer(for: codebaseLocation)
                
                state = .retrievingCodebase(.retrieveSymbolsAndRefs)
                
                let codebase = try await CodeFolder.retrieveSymbolsAndReferences(for: codebaseWithoutSymbols,
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
    
    private func readCodebaseFolder(from codebaseLocation: LSP.CodebaseLocation) -> CodeFolder?
    {
        do
        {
            return try ProcessingSteps.readFolder(from: codebaseLocation)
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
        var symbolDataHash = [CodeSymbolArtifact: CodeSymbol]()
        let architecture = ProcessingSteps.generateArchitecture(from: codebase,
                                                                using: &symbolDataHash)
        
        // add dependencies between sibling symbols
        state = .visualizingCodebaseArchitecture(.addSiblingSymbolDependencies)
        ProcessingSteps.addSymbolDependencies(in: architecture,
                                              using: &symbolDataHash)
        
        // add dependencies on higher levels (across scopes)
        state = .visualizingCodebaseArchitecture(.calculateHigherLevelDependencies)
        await ProcessingSteps.addHigherLevelDependencies(in: architecture)
        
        return architecture
    }
    
    // MARK: - State
    
    public var codebaseDisplayName: String { state.codebaseName ?? "Untitled Codebase" }
    
    @Published public var state = ProcessorState.empty
}

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
    
    static func generateArchitecture(from folder: CodeFolder,
                                     using symbolDataHash: inout [CodeSymbolArtifact: CodeSymbol]) -> CodeFolderArtifact
    {
        CodeFolderArtifact(codeFolder: folder,
                           scope: nil,
                           symbolDataHash: &symbolDataHash)
    }
    
    static func addSymbolDependencies(in architecture: CodeFolderArtifact,
                                using symbolDataHash: inout [CodeSymbolArtifact: CodeSymbol])
    {
        architecture.addSymbolDependencies(symbolDataHash: symbolDataHash)
        symbolDataHash.removeAll()
    }
    
    static func addHigherLevelDependencies(in architecture: CodeFolderArtifact) async
    {
        await Task.detached
        {
            architecture.addCrossScopeDependencies()
        }
        .value
    }
}
