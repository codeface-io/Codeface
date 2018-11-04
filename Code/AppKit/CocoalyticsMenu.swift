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
            appMenu.insertItem(NSMenuItem.separator(), at: 1)
        }
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        return true
    }
    
    private lazy var directoryItem: NSMenuItem =
    {
        let item = NSMenuItem(title: "Open Code Folder...",
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
            folder in CodeFolder.shared.update(with: folder)
        }
    }
}
