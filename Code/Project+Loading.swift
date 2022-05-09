import Foundation
import SwiftyToolz

extension Project
{
    static func loadNewProject(description: Description) throws
    {
        guard description.rootFolder.startAccessingSecurityScopedResource() else
        {
            throw "Couldn't access security scoped folder"
        }
        
        defer { description.rootFolder.stopAccessingSecurityScopedResource() }
        
        try loadProject(description: description)
        
        lastFolder = description.rootFolder
    }
    
    static func loadLastProject(language: String,
                                codeFileEndings: [String]) throws
    {
        // TODO: persist whole project description
        guard let lastFolder = lastFolder else { return }
        
        guard lastFolder.startAccessingSecurityScopedResource() else
        {
            throw "Couldn't access security scoped folder"
        }
        
        defer { lastFolder.stopAccessingSecurityScopedResource() }
        
        try loadProject(description: .init(rootFolder: lastFolder,
                                           language: language,
                                           codeFileEndings: codeFileEndings))
    }
    
    private static func loadProject(description: Description) throws
    {
        Project.active = try Project(description: description)
        
        try Project.active?.startAnalysis()
    }
    
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
                let bookmarkData = try newURL.bookmarkData(options: .withSecurityScope,
                                                       includingResourceValuesForKeys: nil,
                                                       relativeTo: nil)
                
                UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
            }
            catch
            {
                log(error)
            }
        }
    }
    
    private static let bookmarkKey = "UserDefaultsKeyLastFolderURLBookmark"
}
