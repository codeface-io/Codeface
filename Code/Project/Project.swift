import Foundation
import SwiftObserver

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
        self.symbolCache = SymbolCache(inspector: try LSPProjectInspector(language: language,
                                                                          folder: folder))
    }
    
    // MARK: - Data Processing
    
    func startAnalysis() throws
    {
        let newRootFolder = try CodeFolder(rootFolderURL,
                                           codeFileEnding: codeFileEnding)
        
        rootFolder = newRootFolder
        
        // TODO: retrieve symbols from symbol cache and use them to complete the artifact tree
        
        rootFolderArtifact = CodeArtifact(folder: newRootFolder)
        
        analyticsStore.set(elements: CodeFileAnalyzer().analyze(newRootFolder))
        
        Self.messenger.send(.didCompleteAnalysis(self))
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
    
    // MARK: - Basic Configuration
    
    private let rootFolderURL: URL
    private let codeFileEnding: String
    private let symbolCache: SymbolCache // retrieves symbols async on demand
}
