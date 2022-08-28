import LSPServiceKit
import Foundation
import SwiftObserver
import SwiftyToolz

@MainActor
public class ProjectAnalysis
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
                        [weak self] error in
                        
                        guard let self = self else { return }
                        
                        self.task?.cancel()
                        self.task = nil
                        
                        if case .running = self.state
                        {
                            self.state = .failed(error.readable.message)
                        }
                    }
                    
                    self.state = .running(.retrieveSymbolArtifacts)
                    try await rootArtifact.addSymbolArtifacts(using: server)
                    
                    self.state = .running(.retrieveDependencies)
                    try await rootArtifact.addDependencies(using: server)
                }
                catch
                {
                    log(warning: "Cannot retrieve code file symbols from LSP server:\n" + error.readable.message)
                    LSPServerManager.shared.serverIsWorking = false
                }
                
                self.state = .running(.calculateMetrics)
                rootArtifact.generateMetrics()
                
                self.state = .running(.sort)
                rootArtifact.sort()
                
                self.state = .running(.createViewModel)
                let rootVM = ArtifactViewModel(folderArtifact: rootArtifact).addDependencies()
                
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
    
    private var task: Task<Void, Error>?
    
    // MARK: - Publish State
    
    @Observable public private(set) var state: State = .stopped
    
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
                 retrieveSymbolArtifacts = "Retrieving symbol artifacts",
                 retrieveDependencies = "Retrieving dependencies",
                 calculateMetrics = "Calculating metrics",
                 sort = "Sorting code artifacts",
                 createViewModel = "Creating view model"
        }
    }
    
    // MARK: - Configure
    
    public let project: LSPProjectDescription
}
