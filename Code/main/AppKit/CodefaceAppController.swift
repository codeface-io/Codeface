import UIToolz
import AppKit

class CodefaceAppController: AppController
{
    init()
    {
        super.init(appView: AnalyticsView(), appMenu: CodefaceMenu())
        startApp()
    }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)
        Loading.loadFromLastFolder()
    }
}
