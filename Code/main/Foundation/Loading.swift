import Foundation
import SwiftyToolz

class Loading
{
    static func load(newFolder: URL)
    {
        do
        {
            load(try ProjectFolder(newFolder))
            lastFolder = newFolder
        }
        catch { log(error) }
    }
    
    static func loadLastOpenFolder()
    {
        guard let lastFolder = lastFolder else { return }
        do { load(try ProjectFolder(lastFolder)) }
        catch { log(error) }
    }
    
    private static func load(_ projectFolder: ProjectFolder)
    {
        let analytics = CodeFileAnalyzer().analyze(projectFolder)
        CodeFileAnalyticsStore.shared.set(elements: analytics)
    }
    
    // TODO: make this bookmarked URL reusable via property wrapper???
    private(set) static var lastFolder: URL?
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
