import AppKit
import UIToolz

class CocoalyticsMenu: Menu, NSMenuItemValidation
{
    init()
    {
        super.init(appName: "Cocoalytics")
        
        if let appMenu = items.first?.submenu
        {
            appMenu.insertItem(reloadItem, at: 0)
            appMenu.insertItem(directoryItem, at: 1)
            appMenu.insertItem(NSMenuItem.separator(), at: 2)
        }
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        switch menuItem
        {
        case reloadItem: return CodeFolder.lastLoadedFolder != nil
        default: return true
        }
    }
    
    private lazy var directoryItem: NSMenuItem =
    {
        let item = NSMenuItem(title: "Load Code Folder...",
                              action: #selector(selectFolder),
                              keyEquivalent: "l")
        
        item.target = self
        item.keyEquivalentModifierMask = [.command]
        
        return item
    }()
    
    @objc private func selectFolder()
    {
        FolderSelectionPanel().selectFolder
        {
            folder in CodeFolder.shared.load(from: folder)
        }
    }
    
    private lazy var reloadItem: NSMenuItem =
    {
        let item = NSMenuItem(title: "Reload",
                              action: #selector(reload),
                              keyEquivalent: "r")
        
        item.target = self
        item.keyEquivalentModifierMask = [.command]
        
        return item
    }()
    
    @objc private func reload()
    {
        CodeFolder.shared.loadFromLastFolder()
    }
}
