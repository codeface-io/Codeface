import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

@MainActor
class Project
{
    // MARK: - Initialization
    
    init(config: Configuration) throws
    {
        guard FileManager.default.itemExists(config.folder) else
        {
            throw "Project folder does not exist: " + config.folder.absoluteString
        }
        
        self.config = config
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
                
//                do
//                {
//                    let (server, initialization) = try getServerAndServerInitialization()
//                    try await initialization.assumeSuccess()
//                    try await rootArtifact.addSymbolArtifacts(using: server)
//                    try await rootArtifact.addDependencies(using: server)
//                }
//                catch
//                {
//                    log(warning: "Cannot retrieve code file symbols from LSP server:\n" + error.readable.message)
//                }
                
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
        try config.folder.mapSecurityScoped
        {
            guard let codeFolder = try CodeFolder($0, codeFileEndings: config.codeFileEndings) else
            {
                throw "Project folder contains no code files with the specified file endings\nFolder: \($0.absoluteString)\nFile endings: \(config.codeFileEndings)"
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
    
    // MARK: - Language Server
    
    private func getServerAndServerInitialization() throws -> (LSP.ServerCommunicationHandler, Task<Void, Error>)
    {
        if let server = server, let initialization = serverInitialization
        {
            return (server, initialization)
        }
        
        let createdServer = try createServer(language: config.language)
        server = createdServer
        
        let createdInitialization = Self.initialize(createdServer, for: config)
        serverInitialization = createdInitialization
        
        return (createdServer, createdInitialization)
    }
    
    private func createServer(language: String) throws -> LSP.ServerCommunicationHandler
    {
        let server = try LSPService.api.language(language.lowercased()).connectToLSPServer()
        
        server.serverDidSendNotification =
        {
            notification in
            
//            log("Server sent notification:\n\(notification.method)\n\(notification.params?.description ?? "nil params")")
        }

        server.serverDidSendErrorOutput =
        {
            _ in
//            log("\(language.capitalized) language server sent message via stdErr:\n\($0)")
        }
        
        server.connection.didSendError =
        {
            error in
            
            log(error)
            
            self.analysis?.cancel()
            self.analysis = nil
            
            if case .running = self.analysisState
            {
                self.analysisState = .failed(error.readable.message)
            }
            
            server.connection.close()
            
            // TODO: do we (why don't we?) need to nil the server after the websocket sent an error, so that the server gets recreated and the websocket connection reinstated?? do we need to close the websocket connection?? ... maybe the LSPServerConnection protocol needs to expose more functions for handling the connection itself, like func closeConnection() and var connectionDidClose ...
        }
        
        server.connection.didClose =
        {
            log(warning: "LSP websocket connection did close")
        }
        
        return server
    }
    
    private static func initialize(_ server: LSP.ServerCommunicationHandler,
                                   for project: Configuration) -> Task<Void, Error>
    {
        Task
        {
            let processID = try await LSPService.api.processID.get()
            
            let _ = try await server.request(.initialize(folder: project.folder,
                                                         clientProcessID: processID))
            
//            try log(initializeResult: initializeResult)
            
            try await server.notify(.initialized)
        }
    }
    
    private var serverInitialization: Task<Void, Error>? = nil
    private var server: LSP.ServerCommunicationHandler? = nil
    
    // MARK: - Configuration
    
    let config: Configuration
    
    struct Configuration: Codable
    {
        var folder: URL
        let language: String
        let codeFileEndings: [String]
    }
}

extension Task where Success == Void
{
    func assumeSuccess() async throws { try await value }
}
