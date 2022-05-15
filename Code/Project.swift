import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class Project
{
    // MARK: - Shared Instance
    
    static func initSharedInstance(with config: Configuration) throws
    {
        shared = try Project(config: config)
    }
    
    private(set) static var shared: Project?
    
    // MARK: - Initialization
    
    private init(config: Configuration) throws
    {
        guard FileManager.default.itemExists(config.folder) else
        {
            throw "Project folder does not exist: " + config.folder.absoluteString
        }
        
        self.config = config
        
        let createdServer = try Self.createServer(language: config.language)
        server = createdServer
        serverInitialization = Self.initialize(createdServer, for: config)
    }
    
    // MARK: - Data Analysis
    
    func startAnalysis() throws
    {
        Task
        {
            let rootFolder = try createRootFolder()
            
            let rootArtifact = CodeArtifact(codeFolder: rootFolder)
            
            if let server = server, let serverInitialization = serverInitialization
            {
                try await serverInitialization.assumeSuccess()
                try await rootArtifact.addSymbolArtifacts(using: server)
            }
            
            rootArtifact.generateMetrics()
            rootArtifact.sort()
            
            let result = AnalysisResult(rootFolder: rootFolder,
                                        rootArtifact: rootArtifact)
            
            analysisResult = result
            
            Self.messenger.send(.didCompleteAnalysis(result))
        }
    }
    
    private func createRootFolder() throws -> CodeFolder
    {
        try config.folder.mapSecurityScoped
        {
            try CodeFolder($0, codeFileEndings: config.codeFileEndings)
        }
    }
    
    var analysisResult: AnalysisResult?
    
    struct AnalysisResult
    {
        // file system hierarchy: relevant directories and files
        var rootFolder: CodeFolder
        
        // artifact hierarchy: each artifact with dependencies, metrics, order
        var rootArtifact: CodeArtifact
    }
    
    // MARK: - Class Based Observability
    
    static let messenger = Messenger<ClassEvent>()
    
    enum ClassEvent
    {
        case didCompleteAnalysis(AnalysisResult)
    }
    
    // MARK: - Language Server
    
    private static func createServer(language: String) throws -> LSP.ServerCommunicationHandler
    {
        let server = try LSPService.api.language(language).connectToLSPServer()
        
        server.serverDidSendNotification =
        {
            notification in
            
//            log("Server sent notification:\n\(notification.method)\n\(notification.params?.description ?? "nil params")")
        }

        server.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Language server: \(errorOutput)")
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
            
            try server.notify(.initialized)
        }
    }
    
    private var serverInitialization: Task<Void, Error>? = nil
    private var server: LSP.ServerCommunicationHandler? = nil
    
    // MARK: - Configuration
    
    struct PersistedConfiguration: Codable
    {
        var folderBookmarkData: Data
        let language: String
        let codeFileEndings: [String]
    }
    
    private let config: Configuration
    
    struct Configuration
    {
        let folder: URL
        let language: String
        let codeFileEndings: [String]
    }
}

extension Task where Success == Void
{
    func assumeSuccess() async throws { try await value }
}
