import LSPServiceKit
import Foundation

enum ProjectDescriptionPersister
{
    static var hasPersistedLastProject: Bool { persistedProjectDescriptionData != nil }
    
    static func persist(_ project: LSPProjectDescription) throws
    {
        let bookmarkData = try project.folder.bookmarkData(options: .withSecurityScope,
                                                          includingResourceValuesForKeys: nil,
                                                          relativeTo: nil)
        
        let persistedProject = PersistedProjectDescription(folderBookmarkData: bookmarkData,
                                                           projectDescription: project)
        
        persistedProjectDescriptionData = try persistedProject.encode() as Data
    }
    
    static func loadProjectConfig() throws -> LSPProjectDescription
    {
        guard let projectData = persistedProjectDescriptionData else
        {
            throw "Found no persisted project configuration"
        }
        
        var persistedProject = try PersistedProjectDescription(jsonData: projectData)
        
        var bookMarkIsStale = false
        
        let folder = try URL(resolvingBookmarkData: persistedProject.folderBookmarkData,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &bookMarkIsStale)
        
        persistedProject.projectDescription.folder = folder
        
        if bookMarkIsStale
        {
            persistedProject.folderBookmarkData = try folder.bookmarkData()
            
            persistedProjectDescriptionData = try persistedProject.encode() as Data
        }
        
        return persistedProject.projectDescription
    }
    
    @UserDefault(key: "persistedProjectConfigData", defaultValue: nil)
    private static var persistedProjectDescriptionData: Data?
}

private struct PersistedProjectDescription: Codable
{
    var folderBookmarkData: Data
    var projectDescription: LSPProjectDescription
}
