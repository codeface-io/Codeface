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
    
    init(folder: URL,
         language: String,
         codeFileEnding: String) throws
    {
        guard FileManager.default.itemExists(folder) else
        {
            throw "Folder does not exist: " + folder.absoluteString
        }
        
        self.rootFolderURL = folder
        self.language = language
        self.codeFileEnding = codeFileEnding
        
        server = try Self.createServer(language: language)
    }
    
    // MARK: - Data Analysis
    
    func startAnalysis() throws
    {
        Task
        {
            let newRootFolder = try CodeFolder(rootFolderURL,
                                               codeFileEnding: codeFileEnding)
            
            rootFolder = newRootFolder
            
            rootFolderArtifact = CodeArtifact(codeFolder: newRootFolder)
            
//            if !isInitialized
//            {
//                try await initializeServer()
//            }
                        
            // TODO: retrieve symbols and use them to complete the artifact tree
            
            rootFolderArtifact?.generateMetricsRecursively()
            
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
        
        server.serverDidSendNotification = { _ in }

        server.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Language server: \(errorOutput)")
        }
        
        return server
    }
    
    private func initializeServer() async throws
    {
        let processID = try await LSPService.api.processID.get()
        
        let result = try await server.request(.initialize(folder: rootFolderURL,
                                                          clientProcessID: processID))
        
        switch result
        {
        case .success(let resultJSON):
            print(resultJSON.description)
            try server.notify(.initialized)
            serverIsInitialized = true
        case .failure(let error):
            throw error
        }
    }
    
    private var serverIsInitialized = false
    
    private let server: LSP.ServerCommunicationHandler
    
    // MARK: - Basic Configuration
    
    private let rootFolderURL: URL
    private let language: String
    private let codeFileEnding: String
}
