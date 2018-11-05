import AppKit
import FoundationToolz
import SwiftObserver

public class MainMenu: Menu
{
    init()
    {
        super.init(title: "Menu Bar")
        
        addItem(NSMenuItem(submenu: appMenu))
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
    
    public let appMenu = AppMenu()
    
    public class AppMenu: NSMenu
    {
        init()
        {
            super.init(title: "Application Menu")
            
            var namePostfix = ""
            
            if let name = appName { namePostfix = " " + name }
            
            addItem(withTitle: "Hide" + namePostfix,
                    action: #selector(NSApplication.hide(_:)),
                    keyEquivalent: "h")
            addItem(withTitle: "Quit" + namePostfix,
                    action: #selector(NSApplication.terminate(_:)),
                    keyEquivalent: "q")
        }
        
        required init(coder decoder: NSCoder) { fatalError() }
    }
}

public class Menu: NSMenu, NSMenuItemValidation
{
    open func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        if let id = menuItem.id
        {
            return validateItem(with: id)
        }
        
        return true
    }
    
    open func validateItem(with id: String) -> Bool { return true }
}

extension NSMenu
{
    func insert(_ items: [NSMenuItem], at index: Int)
    {
        guard index <= numberOfItems else
        {
            log(error: "Menu item index is out of bounds.")
            return
        }
        
        for i in 0 ..< items.count
        {
            insertItem(items[i], at: i + index)
        }
    }
}
