import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import Combine
import SwiftyToolz

public actor ProjectProcessor: ObservableObject
{
    // MARK: - Initialize
    
    public init(codebase: CodeFolder)
    {
        self.init(state: .didRetrieveCodebase(codebase))
    }
    
    public init(codebaseLocation: LSP.CodebaseLocation) throws
    {
        guard FileManager.default.itemExists(codebaseLocation.folder) else
        {
            throw "Project folder does not exist: " + codebaseLocation.folder.absoluteString
        }
        
        self.init(state: .didLocateCodebase(codebaseLocation))
    }
    
    private init(state: State)
    {
        _state = Published(initialValue: state)
    }
    
    // MARK: - Run Processing
    
    public func run() async
    {
        // get codebase
        guard let codebase = await retrieveCodebase() else { return }
        
        // generate architecture
        let codebaseArchitecture = generateArchitecture(from: codebase)
        
        // analyze architecture
        state = .visualizingCodebaseArchitecture(.calculateMetrics)
        codebaseArchitecture.calculateSizeMetricsRecursively()
        codebaseArchitecture.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
        codebaseArchitecture.calculateCycleMetricsRecursively()
        
        // visualize architecture
        state = .visualizingCodebaseArchitecture(.sortCodeArtifacts)
        codebaseArchitecture.traverseDepthFirst { $0.sort() }
        
        state = .visualizingCodebaseArchitecture(.createViewModels)
        let architectureViewModel = await ArtifactViewModel(folderArtifact: codebaseArchitecture,
                                                            isPackage: codebase.looksLikeAPackage)
        await architectureViewModel.addDependencies()
        
        state = .didVisualizeCodebaseArchitecture(codebase, architectureViewModel)
    }
    
    private func retrieveCodebase() async -> CodeFolder?
    {
        switch state
        {
        case .didLocateCodebase(let codebaseLocation):
            state = .retrievingCodebase(.readFolder)
            guard let codebase = readCodebaseFolder(from: codebaseLocation) else { return nil }
            
            do
            {
                state = .retrievingCodebase(.connectToLSPServer)
                let server = try await LSP.ServerManager.shared.initializeServer(for: codebaseLocation)
                
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
    
    // MARK: - Publish Current State
    
    @Published public private(set) var state: State
    
    public enum State
    {
        var codebase: CodeFolder?
        {
            switch self
            {
            case .didRetrieveCodebase(let codebase): return codebase
            case .didVisualizeCodebaseArchitecture(let codebase, _): return codebase
            default: return nil
            }
        }
        
        case didLocateCodebase(LSP.CodebaseLocation),
             retrievingCodebase(CodebaseRetrievalStep),
             didRetrieveCodebase(CodeFolder),
             visualizingCodebaseArchitecture(CodebaseArchitectureVisualizationStep),
             didVisualizeCodebaseArchitecture(CodeFolder, ArtifactViewModel),
             failed(String)
        
        public enum CodebaseRetrievalStep: String, Equatable
        {
            case readFolder = "Reading raw data from codebase folder",
                 connectToLSPServer = "Connecting to LSP server",
                 retrieveSymbols = "Retrieving symbols from LSP server",
                 retrieveReferences = "Retrieving symbol references from LSP server"
        }
        
        public enum CodebaseArchitectureVisualizationStep: String, Equatable
        {
            case generateArchitecture = "Extracting basic codebase architecture",
                 addSiblingSymbolDependencies = "Adding dependencies between sibling symbols",
                 calculateHigherLevelDependencies = "Calculating higher level dependencies",
                 calculateMetrics = "Calculating metrics",
                 sortCodeArtifacts = "Sorting code artifacts",
                 createViewModels = "Generating code artifact view models"
        }
    }
}
