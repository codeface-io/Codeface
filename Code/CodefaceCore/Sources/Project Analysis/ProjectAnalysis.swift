import LSPServiceKit
import Foundation
import Combine
import SwiftyToolz

public actor ProjectAnalysis: ObservableObject
{
    // MARK: - Initialize
    
    public init(project: LSPProjectDescription) throws
    {
        guard FileManager.default.itemExists(project.folder) else
        {
            throw "Project folder does not exist: " + project.folder.absoluteString
        }
        
        self.project = project
    }
    
    // MARK: - Analyze
    
    public func start() throws
    {
        self.state = .running(.readFolder)
        
        task = Task
        {
            do
            {
                let rootFolder = try readRootFolder()
                
                self.state = .running(.createRootFolderArtifact)
                let rootArtifact = CodeFolderArtifact(codeFolder: rootFolder, scope: nil)
                
                do
                {
                    self.state = .running(.connectToLSPServer)
                    
                    let server = try await LSPServerManager.shared.getServer(for: project)
                    {
                        error in
                        
                        Task
                        {
                            [weak self] in
                            
                            await self?.serverInitializationFailed(with: error)
                        }
                    }
                    
                    self.state = .running(.retrieveSymbols)
                    try await rootArtifact.addSymbolArtifacts(using: server)
                    
                    self.state = .running(.retrieveReferences)
                    try await rootArtifact.requestReferences(from: server)
                }
                catch
                {
                    log(warning: "Cannot retrieve code file symbols from LSP server:\n" + error.readable.message)
                    LSPServerManager.shared.serverIsWorking = false
                }
                
                self.state = .running(.calculateDependencies)
                rootArtifact.generateDependencies()
                
                self.state = .running(.calculateMetrics)
                rootArtifact.calculateSizeMetricsRecursively()
                rootArtifact.recursivelyPruneDependenciesAndCalculateDependencyMetrics()
                rootArtifact.calculateCycleMetricsRecursively()
                
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
        try project.folder.mapSecurityScoped
        {
            guard let codeFolder = try CodeFolder($0, codeFileEndings: project.codeFileEndings) else
            {
                throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(project.codeFileEndings)"
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
            case readFolder = "Reading root folder",
                 createRootFolderArtifact = "Creating root folder artifact",
                 connectToLSPServer = "Connecting to LSP server",
                 retrieveSymbols = "Retrieving symbols",
                 retrieveReferences = "Retrieving symbol references",
                 calculateDependencies = "Calculating code artifacts dependencies",
                 calculateMetrics = "Calculating code artifacts metrics",
                 sortCodeArtifacts = "Sorting code artifacts",
                 createViewModels = "Creating code artifact view models"
        }
    }
    
    // MARK: - Configure
    
    public let project: LSPProjectDescription
}
