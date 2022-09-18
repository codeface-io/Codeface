import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation

public enum CodebaseLocationPersister
{
    public static var hasPersistedLastCodebaseLocation: Bool { persistedCodebaseLocationData != nil }
    
    static func persist(_ location: LSP.CodebaseLocation) throws
    {
        let bookmarkData = try location.folder.bookmarkData(options: .withSecurityScope,
                                                            includingResourceValuesForKeys: nil,
                                                            relativeTo: nil)
        
        let persistedLocation = PersistedCodebaseLocation(folderBookmarkData: bookmarkData,
                                                          codebaseLocation: location)
        
        persistedCodebaseLocationData = try persistedLocation.encode() as Data
        
        Self.cachedLocation = location
    }
    
    static func loadCodebaseLocation() throws -> LSP.CodebaseLocation
    {
        guard let locationData = persistedCodebaseLocationData else
        {
            throw "Found no persisted codebase location"
        }
        
        var persistedLocation = try PersistedCodebaseLocation(jsonData: locationData)
        
        var bookMarkIsStale = false
        
        let folder = try URL(resolvingBookmarkData: persistedLocation.folderBookmarkData,
                             options: .withSecurityScope,
                             relativeTo: nil,
                             bookmarkDataIsStale: &bookMarkIsStale)
        
        persistedLocation.codebaseLocation.folder = folder
        
        if bookMarkIsStale
        {
            persistedLocation.folderBookmarkData = try folder.bookmarkData()
            
            persistedCodebaseLocationData = try persistedLocation.encode() as Data
        }
        
        Self.cachedLocation = persistedLocation.codebaseLocation
        
        return persistedLocation.codebaseLocation
    }
    
    @UserDefault(key: "persistedCodebaseLocationData", defaultValue: nil)
    private static var persistedCodebaseLocationData: Data?
    
    public static var cachedLocation: LSP.CodebaseLocation?
}

private struct PersistedCodebaseLocation: Codable
{
    var folderBookmarkData: Data
    var codebaseLocation: LSP.CodebaseLocation
}
