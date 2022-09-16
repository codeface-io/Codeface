import LSPServiceKit
import SwiftLSP
import Foundation
import Combine
import SwiftyToolz

public actor ProjectProcessor: ObservableObject
{
    // MARK: - Initialize
    
    public init(location: LSP.ProjectLocation) throws
    {
        guard FileManager.default.itemExists(location.folder) else
        {
            throw "Project folder does not exist: " + location.folder.absoluteString
        }
        
        projectName = location.folder.lastPathComponent
        
        _state = Published(initialValue: .didLocateProject(location))
    }
    
    // MARK: - Run Processing
    
    public func run() async
    {
        // get data
        guard let projectData = await retrieveProjectData() else { return }
        
        // generate architecture
        let projectArchitecture = generateProjectArchitecture(from: projectData)
        
        // analyze architecture
        state = .visualizingProjectArchitecture(.calculateMetrics)
        projectArchitecture.calculateSizeMetricsRecursively()
        projectArchitecture.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
        projectArchitecture.calculateCycleMetricsRecursively()
        
        // visualize architecture
        state = .visualizingProjectArchitecture(.sortCodeArtifacts)
        projectArchitecture.traverseDepthFirst { $0.sort() }
        
        state = .visualizingProjectArchitecture(.createViewModels)
        let projectVM = await ArtifactViewModel(folderArtifact: projectArchitecture,
                                                isPackage: projectData.looksLikeAPackage)
        await projectVM.addDependencies()
        
        state = .didVisualizeProjectArchitecture(projectData, projectVM)
    }
    
    private func retrieveProjectData() async -> CodeFolder?
    {
        switch state
        {
        case .didLocateProject(let projectLocation):
            state = .retrievingProjectData(.readFolder)
            projectData = nil
            guard let newProjectData = readRootFolder(from: projectLocation) else { return nil }
            projectData = newProjectData
            
            do
            {
                state = .retrievingProjectData(.connectToLSPServer)
                let server = try await LSP.ServerManager.shared.getServer(for: projectLocation)
                
                state = .retrievingProjectData(.retrieveSymbols)
                try await newProjectData.retrieveSymbolData(from: server)
                
                state = .retrievingProjectData(.retrieveReferences)
                try await newProjectData.retrieveSymbolReferences(from: server)
            }
            catch
            {
                log(warning: "Cannot talk to LSP server: " + error.readable.message)
                LSP.ServerManager.shared.serverIsWorking = false
            }
            
            state = .didRetrieveProjectData(newProjectData)
            
            return newProjectData
        case .didRetrieveProjectData(let projectData):
            return projectData
        case .didVisualizeProjectArchitecture(let projectData, _):
            return projectData
        default:
            log(error: "processor can't start processing as it is in state \(state)")
            return nil
        }
    }
    
    private func readRootFolder(from projectLocation: LSP.ProjectLocation) -> CodeFolder?
    {
        do
        {
            return try projectLocation.folder.mapSecurityScoped
            {
                guard let codeFolder = try CodeFolder($0, codeFileEndings: projectLocation.codeFileEndings) else
                {
                    throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(projectLocation.codeFileEndings)"
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
    
    private var projectData: CodeFolder?
    
    private func generateProjectArchitecture(from projectData: CodeFolder) -> CodeFolderArtifact
    {
        // generate basic hierarchy
        state = .visualizingProjectArchitecture(.generateArchitecture)
        var symbolDataHash = [CodeSymbolArtifact: CodeSymbolData]()
        let projectArchitecture = CodeFolderArtifact(codeFolder: projectData,
                                                     scope: nil,
                                                     symbolDataHash: &symbolDataHash)
        
        // add dependencies between sibling symbols
        state = .visualizingProjectArchitecture(.addSiblingSymbolDependencies)
        projectArchitecture.addSymbolDependencies(symbolDataHash: symbolDataHash)
        symbolDataHash.removeAll()
        
        // add dependencies on higher levels (across scopes)
        state = .visualizingProjectArchitecture(.calculateHigherLevelDependencies)
        projectArchitecture.addCrossScopeDependencies()
        
        return projectArchitecture
    }
    
    // MARK: - Publish State
    
    @Published public private(set) var state: State
    
    public enum State: Equatable
    {
        var projectData: CodeFolder?
        {
            switch self
            {
            case .didRetrieveProjectData(let projectData): return projectData
            case .didVisualizeProjectArchitecture(let projectData, _): return projectData
            default: return nil
            }
        }
        
        case didLocateProject(LSP.ProjectLocation),
             retrievingProjectData(ProjectDataRetrievalStep),
             didRetrieveProjectData(CodeFolder),
             visualizingProjectArchitecture(ProjectArchitectureVisualizationStep),
             didVisualizeProjectArchitecture(CodeFolder, ArtifactViewModel),
             failed(String)
        
        public enum ProjectDataRetrievalStep: String, Equatable
        {
            case readFolder = "Reading raw data drom project folder",
                 connectToLSPServer = "Connecting to LSP server",
                 retrieveSymbols = "Retrieving symbols from LSP server",
                 retrieveReferences = "Retrieving symbol references from LSP server"
        }
        
        public enum ProjectArchitectureVisualizationStep: String, Equatable
        {
            case generateArchitecture = "Generating basic project architecture",
                 addSiblingSymbolDependencies = "Adding dependencies between sibling symbols",
                 calculateHigherLevelDependencies = "Calculating higher level dependencies",
                 calculateMetrics = "Calculating metrics",
                 sortCodeArtifacts = "Sorting code artifacts",
                 createViewModels = "Generating code artifact view models"
        }
    }
    
    // MARK: - Configure
    
    public let projectName: String
}
