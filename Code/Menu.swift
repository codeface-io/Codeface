import AppKit

class Menu: NSMenu
{
    init()
    {
        super.init(title: "Cocoalytics Menu Bar")
        
        addItem(NSMenuItem(with: ApplicationMenu()))
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}
