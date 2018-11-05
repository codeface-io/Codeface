import AppKit
import UIToolz

class CocoalyticsMenu: MainMenu
{
    override init()
    {
        super.init()
        
        insert(topItems, at: 0)
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    override func validateItem(with id: String) -> Bool
    {
        return id != reloadID || CodeFolder.lastLoadedFolder != nil
    }
    
    private lazy var topItems: [NSMenuItem] =
    [
        makeItem("Reload", key: "r", id: reloadID)
        {
            CodeFolder.shared.loadFromLastFolder()
        },
        makeItem("Load Code Folder...", key: "l")
        {
            FolderSelectionPanel().selectFolder
            {
                folder in CodeFolder.shared.load(from: folder)
            }
        },
        NSMenuItem.separator()
    ]
    
    private let reloadID = "reload"
}
