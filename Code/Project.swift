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
        
        self.description = description
        
        server = try Self.createServer(language: description.language)
    }
    
    // MARK: - Data Analysis
    
    func startAnalysis() throws
    {
        Task
        {
            let newRootFolder = try CodeFolder(description.rootFolder,
                                               codeFileEndings: description.codeFileEndings)
            
            rootFolder = newRootFolder
            
            let newRootFolderArtifact = CodeArtifact(codeFolder: newRootFolder)
            
            rootFolderArtifact = newRootFolderArtifact
            
            try await serverInitialization.assumeSuccess()
            
            try await newRootFolderArtifact.reloadDocumentSymbols(from: server,
                                                                  language: description.language)
            
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
    
    private lazy var serverInitialization = initializeServer()
    
    private func initializeServer() -> Task<Void, Error>
    {
        Task
        {
            let processID = try await LSPService.api.processID.get()
            
            _ = try await server.request(.initialize(folder: description.rootFolder,
                                                     clientProcessID: processID))
            
            try server.notify(.initialized)
        }
    }
    
    private let server: LSP.ServerCommunicationHandler
    
    // MARK: - Description
    
    private let description: Description
    
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
