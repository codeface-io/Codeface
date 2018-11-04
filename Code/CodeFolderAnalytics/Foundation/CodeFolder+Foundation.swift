import Foundation

extension CodeFolder
{
    func update(with folder: URL)
    {
        let manager = FileManager.default
        
        let unwantedFolders = ["Pods", "Carthage", "Example%20Projects"]
        
        guard let files = manager.files(inDirectory: folder,
                                        extension: "swift",
                                        skipFolders: unwantedFolders)
        else { return }
        
        let analytics = files.compactMap
        {
            CodeFileAnalytics(file: $0, folder: folder)
        }
        
        set(analytics: analytics, path: folder.path)
    }
}
