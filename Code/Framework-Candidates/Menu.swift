import AppKit

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
