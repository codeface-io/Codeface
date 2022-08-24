import LSPServiceKit
import Foundation
import SwiftObserver
import SwiftyToolz

@MainActor
public class ProjectAnalysis
{
    // MARK: - Initialization
    
    public init(project: LSPProjectDescription) throws
    {
        guard FileManager.default.itemExists(project.folder) else
        {
            throw "Project folder does not exist: " + project.folder.absoluteString
        }
        
        self.project = project
    }
    
    // MARK: - Analysis
    
    public func start() throws
    {
        self.state = .running
        
        task = Task
        {
            do
            {
                let rootFolder = try readRootFolder()
                let rootArtifact = CodeFolderArtifact(codeFolder: rootFolder,
                                                      scope: nil)
                
                do
                {
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
                    try await rootArtifact.addSymbolArtifacts(using: server)
                    try await rootArtifact.addDependencies(using: server)
                }
                catch
                {
                    log(warning: "Cannot retrieve code file symbols from LSP server:\n" + error.readable.message)
                    LSPServerManager.shared.serverIsWorking = false
                }
                
                rootArtifact.generateMetrics()
                rootArtifact.sort()
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
    
    @Observable public private(set) var state: State = .stopped
    
    public enum State: Equatable
    {
        case stopped,
             running,
             succeeded(ArtifactViewModel),
             failed(String)
    }
    
    // MARK: - Configuration
    
    public let project: LSPProjectDescription
}
