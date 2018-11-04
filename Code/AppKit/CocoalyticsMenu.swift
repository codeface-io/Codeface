import AppKit
import UIToolz

class CocoalyticsMenu: Menu, NSMenuItemValidation
{
    init()
    {
        super.init(appName: "Cocoalytics")
        
        if let appMenu = items.first?.submenu
        {
            let reloadItem = makeItem("Reload", key: "r", id: reloadID)
            {
                CodeFolder.shared.loadFromLastFolder()
            }
            
            appMenu.insertItem(reloadItem, at: 0)
            
            let loadItem = makeItem("Load Code Folder...", key: "l", id: loadID)
            {
                FolderSelectionPanel().selectFolder
                {
                    folder in CodeFolder.shared.load(from: folder)
                }
            }
            
            appMenu.insertItem(loadItem, at: 1)
            
            appMenu.insertItem(NSMenuItem.separator(), at: 2)
        }
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        switch menuItem.id
        {
        case reloadID: return CodeFolder.lastLoadedFolder != nil
        default: return true
        }
    }
    
    private let reloadID = "reload", loadID = "load"
}
