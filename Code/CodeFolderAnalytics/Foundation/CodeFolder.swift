import Foundation

class CodeFolder
{
    init(url: URL)
    {
        self.url = url
    }
    
    func loadFiles() -> [CodeFile]?
    {
        let manager = FileManager.default
        
        let unwantedFolders = ["Pods", "Carthage", "Example%20Projects"]
        
        guard let files = manager.files(inDirectory: url,
                                        extension: "swift",
                                        skipFolders: unwantedFolders)
        else
        {
            return nil
        }
        
        CodeFolder.lastURL = url
        
        return files.compactMap { CodeFile(file: $0, folder: url) }
    }
    
    let url: URL
    
    static var lastURL: URL?
    {
        get { return UserDefaults.standard.url(forKey: folderKey) }
        set { UserDefaults.standard.set(newValue, forKey: folderKey) }
    }
    
    private static let folderKey = "UserDefaultsKeyFolderURL"
}
