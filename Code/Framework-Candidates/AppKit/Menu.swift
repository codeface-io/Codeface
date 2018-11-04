import AppKit
import FoundationToolz

class Menu: NSMenu
{
    init()
    {
        super.init(title: "Menu Bar")
        
        addItem(NSMenuItem(submenu: ApplicationMenu()))
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}

class ApplicationMenu: NSMenu
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
