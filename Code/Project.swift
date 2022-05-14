import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class Project
{
    // MARK: - Active Instance
    
    static var active: Project?
    
    // MARK: - Initialization
    
    init(description: Description) throws
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
            let newRootFolder = try CodeFolder(projectDescription.rootFolder,
                                               codeFileEndings: projectDescription.codeFileEndings)
            
            rootFolder = newRootFolder
            
            let newRootFolderArtifact = CodeArtifact(codeFolder: newRootFolder)
            
            rootFolderArtifact = newRootFolderArtifact
            
            try await serverInitialization.assumeSuccess()
            
            try await newRootFolderArtifact.reloadDocumentSymbols(from: server)
            
            newRootFolderArtifact.generateMetricsRecursively()
            newRootFolderArtifact.sortPartsRecursively()
            
            Self.messenger.send(.didCompleteAnalysis(self))
        }
    }
    
    // raw input: directories and files
    var rootFolder: CodeFolder?
    
    // analysis results: artifact tree, dependencies, metrics
    var rootFolderArtifact: CodeArtifact?
    
    // MARK: - Class Based Observability
    
    static let messenger = Messenger<ClassEvent>()
    
    enum ClassEvent
    {
        case didCompleteAnalysis(Project)
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
