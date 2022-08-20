import LSPServiceKit
import Foundation

enum ProjectConfigPersister
{
    static var hasPersistedLastProjectConfig: Bool { persistedProjectConfigData != nil }
    
    static func persist(projectConfig config: LSPProjectConfiguration) throws
    {
        let bookmarkData = try config.folder.bookmarkData(options: .withSecurityScope,
                                                          includingResourceValuesForKeys: nil,
                                                          relativeTo: nil)
        
        let persistedConfig = PersistedProjectConfiguration(folderBookmarkData: bookmarkData,
                                                            configuration: config)
        
        persistedProjectConfigData = try persistedConfig.encode() as Data
    }
    
    static func loadProjectConfig() throws -> LSPProjectConfiguration
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
    
    @UserDefault(key: "persistedProjectConfigData", defaultValue: nil)
    private static var persistedProjectConfigData: Data?
}

private struct PersistedProjectConfiguration: Codable
{
    var folderBookmarkData: Data
    var configuration: LSPProjectConfiguration
}
