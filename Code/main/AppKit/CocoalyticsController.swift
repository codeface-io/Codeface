import UIToolz

class CocoalyticsController: AppController
{
    init() { super.init(withMainMenu: CocoalyticsMenu()) }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)
        
        window.contentViewController = viewController
        
        Loading.loadFromLastFolder()
    }
    
    private let viewController = ViewController<AnalyticsView>()
}
