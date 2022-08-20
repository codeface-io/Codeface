import LSPServiceKit
import CodefaceCore
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

@MainActor
class Project
{
    // MARK: - Initialization
    
    init(config: LSPProjectConfiguration) throws
    {
        guard FileManager.default.itemExists(config.folder) else
        {
            throw "Project folder does not exist: " + config.folder.absoluteString
        }
        
        self.project = config
    }
    
    // MARK: - Data Analysis
    
    func startAnalysis() throws
    {
        self.analysisState = .running
        
        analysis = Task
        {
            do
            {
                let rootFolder = try createRootFolder()
                let rootArtifact = CodeFolderArtifact(codeFolder: rootFolder,
                                                      scope: nil)
                
                do
                {
                    let (server, initialization) = try LSPServerManager.shared.getServerAndInitialization(for: project)
                    {
                        [weak self] error in
                        
                        guard let self = self else { return }
                        
                        self.analysis?.cancel()
                        self.analysis = nil
                        
                        if case .running = self.analysisState
                        {
                            self.analysisState = .failed(error.readable.message)
                        }
                    }
                    try await initialization.assumeSuccess()
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
                self.analysisState = .succeeded(rootVM)
            }
            catch
            {
                self.analysisState = .failed(error.readable.message)
                throw error
            }
        }
    }
    
    private func createRootFolder() throws -> CodeFolder
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
    
    private var analysis: Task<Void, Error>?
    
    @Observable private(set) var analysisState: AnalysisState = .stopped
    
    enum AnalysisState: Equatable
    {
        case stopped,
             running,
             succeeded(ArtifactViewModel),
             failed(String)
    }
    
    // MARK: - Configuration
    
    let project: LSPProjectConfiguration
}

extension Task where Success == Void
{
    func assumeSuccess() async throws { try await value }
}
