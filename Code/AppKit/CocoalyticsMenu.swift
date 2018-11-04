import AppKit
import UIToolz

class CocoalyticsMenu: Menu, NSMenuItemValidation
{
    init()
    {
        super.init(appName: "Cocoalytics")
        
        if let appMenu = items.first?.submenu
        {
            appMenu.insertItem(directoryItem, at: 0)
        }
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        return true
    }
    
    private lazy var directoryItem: NSMenuItem =
    {
        let item = NSMenuItem(title: "Select Code Folder...",
                              action: #selector(selectFolder),
                              keyEquivalent: "o")
        
        item.target = self
        item.keyEquivalentModifierMask = [.command]
        
        return item
    }()
    
    @objc private func selectFolder()
    {
        FolderSelectionPanel().selectFolder
        {
            folder in
            
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

            Store.shared.set(analytics: analytics, folderPath: folder.path)
        }
    }
}
