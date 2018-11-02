import AppKit

// MARK: - Framework Candidates

class ApplicationMenu: NSMenu
{
    init(appName: String)
    {
        super.init(title: "Application Menu")
        
        addItem(withTitle: "Hide \(appName)",
                action: #selector(NSApplication.hide(_:)),
                keyEquivalent: "h")
        addItem(withTitle: "Quit \(appName)",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q")
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}
