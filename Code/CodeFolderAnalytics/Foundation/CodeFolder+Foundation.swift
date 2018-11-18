import Foundation

extension CodeFolder
{
    func loadFromLastFolder()
    {
        guard let folder = CodeFolder.lastLoadedFolder else { return }
        
        load(from: folder)
    }
    
    func load(from folder: URL)
    {
        let manager = FileManager.default
        
        let unwantedFolders = ["Pods", "Carthage", "Example%20Projects"]
        
        guard let files = manager.files(inDirectory: folder,
                                        extension: "swift",
                                        skipFolders: unwantedFolders)
        else { return }
        
        CodeFolder.lastLoadedFolder = folder
        
        CodeFileStore.shared.elements = files.compactMap
        {
            CodeFile(file: $0, folder: folder)
        }
        
        let analyzer = CodeFileAnalyzer(typeRetriever: SwiftASTTypeRetriever())
        
        let analytics = analyzer.analyze(CodeFileStore.shared.elements)
        
        set(analytics: analytics, path: folder.path)
    }

    static var lastLoadedFolder: URL?
    {
        get { return UserDefaults.standard.url(forKey: folderKey) }
        set { UserDefaults.standard.set(newValue, forKey: folderKey) }
    }
    
    private static let folderKey = "UserDefaultsKeyFolderURL"
}
