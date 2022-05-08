import Foundation
import SwiftObserver

class Project
{
    // MARK: - Active Instance
    
    static var active: Project?
    {
        didSet { messenger.send(.didSetActiveProject(active)) }
    }
    
    static let messenger = Messenger<ClassEvent>()
    
    enum ClassEvent { case didSetActiveProject(Project?) }
    
    // MARK: - Initialization
    
    init(folder: URL, inspector: LSPProjectInspector) throws
    {
        rootFolder = try CodeFolder(folder)
        self.inspector = inspector
        symbolCache = SymbolCache(inspector: inspector)
        analyticsStore.set(elements: CodeFileAnalyzer().analyze(rootFolder))
    }
    
    // MARK: - Data
    
    let analyticsStore = CodeFileAnalyticsStore()
    let symbolCache: SymbolCache
    let inspector: LSPProjectInspector
    let rootFolder: CodeFolder
}
