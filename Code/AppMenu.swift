import AppKit

class ApplicationMenu: NSMenu
{
    init()
    {
        super.init(title: "Application Menu")
        
        addItem(withTitle: "Hide Cocoalytics",
                action: #selector(NSApplication.hide(_:)),
                keyEquivalent: "h")
        addItem(withTitle: "Quit Cocoalytics",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q")
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}
