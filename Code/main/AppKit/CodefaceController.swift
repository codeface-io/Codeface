import UIToolz

class CodefaceController: AppController
{
    init() { super.init(withMainMenu: CodefaceMenu()) }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)
        
        window.contentViewController = viewController
        
        Loading.loadFromLastFolder()
    }
    
    private let viewController = ViewController<AnalyticsView>()
}
