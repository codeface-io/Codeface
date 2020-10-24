import UIToolz
import AppKit

@main
class CodefaceAppController: AppController
{
    static func main() { instance.startApp() }
    
    private static let instance = CodefaceAppController(appView: AnalyticsView(),
                                                        appMenu: CodefaceMenu())
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)
        Loading.loadFilesFromLastFolder()
        
        LSPServiceTest.start()
    }
}
