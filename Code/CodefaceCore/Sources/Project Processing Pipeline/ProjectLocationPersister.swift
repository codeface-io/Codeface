import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation

public enum ProjectLocationPersister
{
    public static var hasPersistedLastProjectLocation: Bool { persistedProjectLocationData != nil }
    
    static func persist(_ project: LSP.ProjectLocation) throws
    {
        let bookmarkData = try project.folder.bookmarkData(options: .withSecurityScope,
                                                           includingResourceValuesForKeys: nil,
                                                           relativeTo: nil)
        
        let persistedProject = PersistedProjectLocation(folderBookmarkData: bookmarkData,
                                                        projectLocation: project)
        
        persistedProjectLocationData = try persistedProject.encode() as Data
    }
    
    static func loadProjectLocation() throws -> LSP.ProjectLocation
    {
        guard let projectData = persistedProjectLocationData else
        {
            throw "Found no persisted project configuration"
        }
        
        var persistedProject = try PersistedProjectLocation(jsonData: projectData)
        
        var bookMarkIsStale = false
        
        let folder = try URL(resolvingBookmarkData: persistedProject.folderBookmarkData,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &bookMarkIsStale)
        
        persistedProject.projectLocation.folder = folder
        
        if bookMarkIsStale
        {
            persistedProject.folderBookmarkData = try folder.bookmarkData()
            
            persistedProjectLocationData = try persistedProject.encode() as Data
        }
        
        return persistedProject.projectLocation
    }
    
    @UserDefault(key: "persistedProjectLocationData", defaultValue: nil)
    private static var persistedProjectLocationData: Data?
}

private struct PersistedProjectLocation: Codable
{
    var folderBookmarkData: Data
    var projectLocation: LSP.ProjectLocation
}
