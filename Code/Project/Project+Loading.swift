import Foundation
import SwiftyToolz

extension Project
{
    static func load(newFolder: URL) throws
    {
        guard newFolder.startAccessingSecurityScopedResource() else
        {
            throw "Couldn't access security scoped folder"
        }
        
        defer { newFolder.stopAccessingSecurityScopedResource() }
        
        try load(newFolder)
        lastFolder = newFolder
    }
    
    static func loadLastOpenFolder() throws
    {
        guard let lastFolder = lastFolder else { return }
        
        guard lastFolder.startAccessingSecurityScopedResource() else
        {
            throw "Couldn't access security scoped folder"
        }
        
        defer { lastFolder.stopAccessingSecurityScopedResource() }
        
        try load(lastFolder)
    }
    
    private static func load(_ folder: URL) throws
    {
        let inspector = try LSPProjectInspector(language: "swift", folder: folder)
        
        Project.active = try Project(folder: folder, inspector: inspector)
    }
    
    // TODO: make this bookmarked URL reusable via property wrapper???
    private static var lastFolder: URL?
    {
        get
        {
            guard let bookmark = UserDefaults.standard.data(forKey: bookmarkKey) else
            {
                return nil
            }
            
            var resultingURL: URL?
            
            do
            {
                var bookMarkIsStale = false
                
                let retrievedURL = try URL(resolvingBookmarkData: bookmark,
                                           options: .withSecurityScope,
                                           relativeTo: nil,
                                           bookmarkDataIsStale: &bookMarkIsStale)
                
                resultingURL = retrievedURL
                
                if bookMarkIsStale
                {
                    let newBookmark = try retrievedURL.bookmarkData()
                    UserDefaults.standard.set(newBookmark, forKey: bookmarkKey)
                }
            }
            catch
            {
                log(error)
            }
            
            return resultingURL
        }
        
        set
        {
            guard let newURL = newValue else
            {
                UserDefaults.standard.set(nil, forKey: bookmarkKey)
                return
            }
            
            do
            {
                let bookmark = try newURL.bookmarkData(options: .withSecurityScope,
                                                       includingResourceValuesForKeys: nil,
                                                       relativeTo: nil)
                
                UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
            }
            catch
            {
                log(error)
            }
        }
    }
    
    private static let bookmarkKey = "UserDefaultsKeyLastFolderURLBookmark"
}
