import SwiftUI
import FoundationToolz
import SwiftyToolz

@main
struct CodefaceApp: App {
    
    // TODO: after launch: try Project.loadLastOpenFolder()
    
    // MARK: - Persist Project Configuration
    
    var body: some Scene {
        Settings {
            Text("Settings View Placeholder")
                .padding()
        }
        
        WindowGroup
        {
            ContentView()
        }
        .commands
        {
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
                        
                        try Project.initSharedInstance(with: config)
                        try Project.shared?.startAnalysis()
                        
                        try persist(lastProjectConfig: config)
                    }
                    catch { log(error) }
                })
                
                Button("Reload Last Project")
                {
                    do
                    {
                        try Project.initSharedInstance(with: loadProjectConfig())
                        try Project.shared?.startAnalysis()
                    }
                    catch { log(error) }
                }
                .keyboardShortcut("r")
                .disabled(persistedProjectConfigData == nil)
            }
        }
    }
    
    @State var isPresented = false
    
    // MARK: - Persist Project Configuration
    
    func persist(lastProjectConfig config: Project.Configuration) throws
    {
        let bookmarkData = try config.folder.bookmarkData(options: .withSecurityScope,
                                                          includingResourceValuesForKeys: nil,
                                                          relativeTo: nil)
        
        let persistedConfig = Project.PersistedConfiguration(folderBookmarkData: bookmarkData,
                                                             language: config.language,
                                                             codeFileEndings: config.codeFileEndings)
        
        persistedProjectConfigData = try persistedConfig.encode() as Data
    }
    
    func loadProjectConfig() throws -> Project.Configuration
    {
        guard let configData = persistedProjectConfigData else
        {
            throw "Found no persisted project configuration"
        }
        
        var persistedProjectConfig = try Project.PersistedConfiguration(jsonData: configData)
        
        var bookMarkIsStale = false
        
        let folder = try URL(resolvingBookmarkData: persistedProjectConfig.folderBookmarkData,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &bookMarkIsStale)
        
        if bookMarkIsStale
        {
            persistedProjectConfig.folderBookmarkData = try folder.bookmarkData()
            
            persistedProjectConfigData = try persistedProjectConfig.encode() as Data
        }
        
        return Project.Configuration(folder: folder,
                                     language: persistedProjectConfig.language,
                                     codeFileEndings: persistedProjectConfig.codeFileEndings)
    }
    
    @AppStorage("persistedProjectConfigData") var persistedProjectConfigData: Data?
}
