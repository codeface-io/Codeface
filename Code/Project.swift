import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class Project
{
    // MARK: - Shared Instance
    
    static func initSharedInstance(with description: Description) throws
    {
        shared = try Project(description: description)
    }
    
    private(set) static var shared: Project?
    
    // MARK: - Initialization
    
    private init(description: Description) throws
    {
        guard FileManager.default.itemExists(description.rootFolder) else
        {
            throw "Project folder does not exist: " + description.rootFolder.absoluteString
        }
        
        projectDescription = description
        
        server = try Self.createServer(language: description.language)
        serverInitialization = Self.initialize(server, for: description)
    }
    
    // MARK: - Data Analysis
    
    func startAnalysis() throws
    {
        Task
        {
            let rootFolder = try createRootFolder()
            
            let rootArtifact = CodeArtifact(codeFolder: rootFolder)
            
            try await serverInitialization.assumeSuccess()
            
            try await rootArtifact.addSymbolArtifacts(using: server)
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
        try projectDescription.rootFolder.mapSecurityScoped
        {
            try CodeFolder($0, codeFileEndings: projectDescription.codeFileEndings)
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
                                   for project: Description) -> Task<Void, Error>
    {
        Task
        {
            let processID = try await LSPService.api.processID.get()
            
            let _ = try await server.request(.initialize(folder: project.rootFolder,
                                                         clientProcessID: processID))
            
//            try log(initializeResult: initializeResult)
            
            try server.notify(.initialized)
        }
    }
    
    private var serverInitialization: Task<Void, Error>
    
    private let server: LSP.ServerCommunicationHandler
    
    // MARK: - Description
    
    private let projectDescription: Description
    
    struct Description
    {
        let rootFolder: URL
        let language: String
        let codeFileEndings: [String]
    }
}

extension Task where Success == Void
{
    func assumeSuccess() async throws { try await value }
}
