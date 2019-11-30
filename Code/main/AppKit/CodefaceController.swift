import UIToolz

class CodefaceController: AppController
{
    override init()
    {
        super.init()
        NSApplication.shared.mainMenu = CodefaceMenu() // must be set before delegate
        window.contentView = AnalyticsView()
    }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)
        
        Loading.loadFromLastFolder()
    }
}
