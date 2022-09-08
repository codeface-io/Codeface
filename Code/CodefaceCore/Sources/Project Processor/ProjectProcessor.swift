import LSPServiceKit
import Foundation
import Combine
import SwiftyToolz

public actor ProjectProcessor: ObservableObject
{
    // MARK: - Initialize
    
    public init(projectLocation: ProjectLocation) throws
    {
        guard FileManager.default.itemExists(projectLocation.folder) else
        {
            throw "Project folder does not exist: " + projectLocation.folder.absoluteString
        }
        
        self.projectLocation = projectLocation
    }
    
    // MARK: - Run Processing
    
    public func run() throws
    {
        self.state = .running(.readFolder)
        
        task = Task
        {
            do
            {
                // load project data from file system and lsp server
                
                let rootFolder = try readRootFolder()
                
                do
                {
                    self.state = .running(.connectToLSPServer)
                    
                    let server = try await LSPServerManager.shared.getServer(for: projectLocation)
                    {
                        error in
                        
                        Task
                        {
                            [weak self] in
                            
                            await self?.serverInitializationFailed(with: error)
                        }
                    }
                    
                    self.state = .running(.retrieveSymbols)
                    try await rootFolder.retrieveSymbolData(from: server)
                    
                    self.state = .running(.retrieveReferences)
                    try await rootFolder.retrieveSymbolReferences(from: server)
                }
                catch
                {
                    log(warning: "Cannot retrieve code file symbols from LSP server:\n" + error.readable.message)
                    LSPServerManager.shared.serverIsWorking = false
                }
                
                // we have the project data. now we build a project-/architecture description
                let rootArtifact = generateProjectArchitecture(fromProjectData: rootFolder)
                
                // arguably, here begins the project analysis
                self.state = .running(.calculateCrossScopeDependencies)
                rootArtifact.addCrossScopeDependencies()
                
                self.state = .running(.calculateMetrics)
                rootArtifact.calculateSizeMetricsRecursively()
                rootArtifact.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
                rootArtifact.calculateCycleMetricsRecursively()
                
                // here begins the project visualization
                self.state = .running(.sortCodeArtifacts)
                rootArtifact.traverseDepthFirst { $0.sort() }
                
                self.state = .running(.createViewModels)
                
                let rootVM = await ArtifactViewModel(folderArtifact: rootArtifact,
                                                     isPackage: rootFolder.looksLikeAPackage).addDependencies()
                
                self.state = .succeeded(rootVM)
            }
            catch
            {
                self.state = .failed(error.readable.message)
                throw error
            }
        }
    }
    
    private func readRootFolder() throws -> CodeFolder
    {
        try projectLocation.folder.mapSecurityScoped
        {
            guard let codeFolder = try CodeFolder($0, codeFileEndings: projectLocation.codeFileEndings) else
            {
                throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(projectLocation.codeFileEndings)"
            }
            
            return codeFolder
        }
    }
    
    private func serverInitializationFailed(with error: Error)
    {
        task?.cancel()
        task = nil
        
        if case .running = state
        {
            state = .failed(error.readable.message)
        }
    }
    
    private func generateProjectArchitecture(fromProjectData rootFolder: CodeFolder) -> CodeFolderArtifact
    {
        state = .running(.generateArchitecture)
        
        var symbolDataHash = [CodeSymbolArtifact: CodeSymbolData]()
        
        let rootArtifact = CodeFolderArtifact(codeFolder: rootFolder,
                                              scope: nil,
                                              symbolDataHash: &symbolDataHash)
        
        rootArtifact.addSymbolDependencies(symbolDataHash: symbolDataHash)
        
        symbolDataHash.removeAll()
        
        return rootArtifact
    }
    
    private var task: Task<Void, Error>?
    
    // MARK: - Publish State
    
    @Published public private(set) var state: State = .stopped
    
    public enum State: Equatable
    {
        case stopped,
             running(Step),
             succeeded(ArtifactViewModel),
             failed(String)
        
        public enum Step: String, Equatable
        {
            case readFolder = "Reading raw data drom project folder",
                 connectToLSPServer = "Connecting to LSP server",
                 retrieveSymbols = "Retrieving symbols from LSP server",
                 retrieveReferences = "Retrieving symbol references from LSP server",
                 generateArchitecture = "Generating project architecture",
                 calculateCrossScopeDependencies = "Calculating dependencies across scopes",
                 calculateMetrics = "Calculating metrics",
                 sortCodeArtifacts = "Sorting code artifacts",
                 createViewModels = "Generating code artifact view models"
        }
    }
    
    // MARK: - Configure
    
    public let projectLocation: ProjectLocation
}