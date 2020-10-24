import Foundation
import SwiftyToolz

class CodeFileLoading
{
    static func loadFilesFromLastFolder() -> [CodeFile]?
    {
        guard let lastFolder = lastFolder else { return nil }
        return loadFiles(from: lastFolder)
    }
    
    static func loadFiles(fromNewFolder newFolder: URL) -> [CodeFile]?
    {
        guard let files = loadFiles(from: newFolder) else { return nil }
        lastFolder = newFolder
        return files
    }
    
    private static func loadFiles(from folder: URL) -> [CodeFile]?
    {
        guard folder.startAccessingSecurityScopedResource() else
        {
            log(error: "Can't access security scoped folder")
            return nil
        }
        
        defer { folder.stopAccessingSecurityScopedResource() }
        
        let manager = FileManager.default
        
        let unwantedFolders = ["Pods", "Carthage", "Example%20Projects"]
        
        guard let fileURLs = manager.files(inDirectory: folder,
                                           extension: "swift",
                                           skipFolders: unwantedFolders)
        else
        {
            return nil
        }
        
        return fileURLs.compactMap { CodeFile(file: $0, folder: folder) }
    }
    
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
