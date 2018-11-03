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
            
            guard let files = manager.files(inDirectory: folder,
                                            extension: "swift") else
            {
                return
            }
        
            var analytics = files.compactMap
            {
                CodeFileAnalytics(file: $0, folder: folder)
            }
            
            analytics.sortByLinesOfCode()
            Store.shared.analytics = analytics
        }
    }
}

// MARK: - Framework Candidates

class Menu: NSMenu
{
    init(appName: String)
    {
        super.init(title: "\(appName) Menu Bar")
        
        addItem(NSMenuItem(submenu: ApplicationMenu(appName: appName)))
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}

class ApplicationMenu: NSMenu
{
    init(appName: String)
    {
        super.init(title: "\(appName) Application Menu")
        
        addItem(withTitle: "Hide \(appName)",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h")
        addItem(withTitle: "Quit \(appName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q")
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}
