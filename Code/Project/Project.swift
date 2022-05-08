import LSPServiceKit
import SwiftLSP
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
        self.codeFileEnding = codeFileEnding
        
        server = try LSPService.api.language(language).connectToLSPServer()
        
        server.serverDidSendNotification = { _ in }

        server.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Language server: \(errorOutput)")
        }
        
        server.serverDidSendErrorResult = { log($0) }
        
        self.symbolCache = SymbolCache(inspector: try LSPProjectInspector(server: server,
                                                                          language: language,
                                                                          folder: folder))
    }
    
    // MARK: - Data Processing
    
    func startAnalysis() throws
    {
        Task
        {
            let newRootFolder = try CodeFolder(rootFolderURL,
                                               codeFileEnding: codeFileEnding)
            
            rootFolder = newRootFolder
            
//            if !isInitialized
//            {
//                try await initializeServer()
//            }
            
            // TODO: retrieve symbols from symbol cache and use them to complete the artifact tree
            
            rootFolderArtifact = CodeArtifact(folder: newRootFolder)
            
            analyticsStore.set(elements: CodeFileAnalyzer().analyze(newRootFolder))
            
            Self.messenger.send(.didCompleteAnalysis(self))
        }
    }
    
    // MARK: - Data Processing Results
    
    // raw directories and files
    var rootFolder: CodeFolder?
    
    // general artifact tree with dependencies and metrics
    var rootFolderArtifact: CodeArtifact?
    
    let analyticsStore = CodeFileAnalyticsStore()
    
    // MARK: - Class Based Observability
    
    static let messenger = Messenger<ClassEvent>()
    
    enum ClassEvent
    {
        case didCompleteAnalysis(Project)
    }
    
    // MARK: - Language Server
    
    private func initializeServer() async throws
    {
        let processID = try await LSPService.api.processID.get()
        
        let initializationResult = try await server.request(.initialize(folder: rootFolderURL,
                                                                        clientProcessID: processID))
        
        switch initializationResult
        {
        case .success(let resultJSON):
            print(resultJSON.description)
            try server.notify(.initialized)
            isInitialized = true
        case .failure(let error):
            throw error
        }
    }
    
    private var isInitialized = false
    
    private let server: LSP.ServerCommunicationHandler
    
    // MARK: - Basic Configuration
    
    private let rootFolderURL: URL
    private let codeFileEnding: String
    private let symbolCache: SymbolCache // retrieves symbols async on demand
}
