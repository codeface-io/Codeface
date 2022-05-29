import SwiftUI
import FoundationToolz
import SwiftyToolz

@main
struct CodefaceApp: App
{
    // MARK: - Create Body
    
    var body: some Scene
    {
        WindowGroup
        {
            ZStack
            {
                CodefaceView(viewModel: codeface)
                
                if isPresentingLSPServiceHint {
                    LSPServiceHint(isBeingPresented: $isPresentingLSPServiceHint)
                }
            }
            .onChange(of: scenePhase)
            {
                switch $0
                {
                case .background: break
                case .active:
                    if persistedProjectConfigData != nil,
                        codeface.activeProject == nil
                    {
                        do { try loadLastProject() }
                        catch { log(error) }
                    }
                case .inactive: break
                @unknown default: break
                }
            }
        }
        .commands
        {
            SidebarCommands()
            
            CommandGroup(before: .sidebar)
            {
                Button("Switch View Mode")
                {
                    switch codeface.displayMode
                    {
                    case .code: codeface.displayMode = .treeMap
                    case .treeMap: codeface.displayMode = .code
                    }
                }
                .keyboardShortcut(.space, modifiers: .shift)
                
                // TODO: only show when we haven't loaded symbols etc.
                Button("Show Symbols, Dependencies etc. ...")
                {
                    isPresentingLSPServiceHint = true
                }
                
                Divider()
            }
            
            CommandGroup(after: .help)
            {
                Button("How to see Symbols, Dependencies etc. ...")
                {
                    isPresentingLSPServiceHint = true
                }
            }
            
            CommandGroup(replacing: .newItem)
            {
                Button("Load Swift Package...")
                {
                    isPresented = true
                }
                .keyboardShortcut("l")
                .fileImporter(isPresented: $isPresented,
                              allowedContentTypes: [.directory],
                              allowsMultipleSelection: false,
                              onCompletion:
                {
                    result in
                    
                    isPresented = false
                    
                    do
                    {
                        let urls = try result.get()
                        
                        guard let firstURL = urls.first else
                        {
                            throw "Empty array of URLs"
                        }
                        
                        let config = Project.Configuration(folder: firstURL,
                                                           language: "swift",
                                                           codeFileEndings: ["swift"])
                        
                        try loadNewProject(with: config)
                    }
                    catch { log(error) }
                })
                
                Button("Reload Last Project")
                {
                    do { try loadLastProject() }
                    catch { log(error) }
                }
                .keyboardShortcut("r")
                .disabled(persistedProjectConfigData == nil)
            }
        }
    }
    
    @State var isPresentingLSPServiceHint = false
    @State var isPresented = false
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Codeface
    
    @MainActor
    private func loadNewProject(with config: Project.Configuration) throws
    {
        try codeface.setAndAnalyzeActiveProject(with: config)
        try persist(projectConfig: config)
    }
    
    @MainActor
    private func loadLastProject() throws
    {
        try codeface.setAndAnalyzeActiveProject(with: loadProjectConfig())
    }
    
    @StateObject private var codeface = Codeface()
    
    // MARK: - Persist Project Configuration
    
    func persist(projectConfig config: Project.Configuration) throws
    {
        let bookmarkData = try config.folder.bookmarkData(options: .withSecurityScope,
                                                          includingResourceValuesForKeys: nil,
                                                          relativeTo: nil)
        
        let persistedConfig = PersistedProjectConfiguration(folderBookmarkData: bookmarkData,
                                                            configuration: config)
        
        persistedProjectConfigData = try persistedConfig.encode() as Data
    }
    
    func loadProjectConfig() throws -> Project.Configuration
    {
        guard let configData = persistedProjectConfigData else
        {
            throw "Found no persisted project configuration"
        }
        
        var persistedConfig = try PersistedProjectConfiguration(jsonData: configData)
        
        var bookMarkIsStale = false
        
        let folder = try URL(resolvingBookmarkData: persistedConfig.folderBookmarkData,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &bookMarkIsStale)
        
        persistedConfig.configuration.folder = folder
        
        if bookMarkIsStale
        {
            persistedConfig.folderBookmarkData = try folder.bookmarkData()
            
            persistedProjectConfigData = try persistedConfig.encode() as Data
        }
        
        return persistedConfig.configuration
    }
    
    @AppStorage("persistedProjectConfigData") var persistedProjectConfigData: Data?
}

struct PersistedProjectConfiguration: Codable
{
    var folderBookmarkData: Data
    var configuration: Project.Configuration
}
