import AppKit

// MARK: - Framework Candidates

class Menu: NSMenu
{
    init(appName: String)
    {
        super.init(title: "\(appName) Menu Bar")
        
        addItem(NSMenuItem(with: ApplicationMenu(appName: appName)))
    }
    
    required init(coder decoder: NSCoder) { fatalError() }
}
