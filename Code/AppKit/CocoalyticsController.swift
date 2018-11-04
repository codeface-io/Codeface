import UIToolz

class CocoalyticsController: AppController
{
    init() { super.init(withMainMenu: CocoalyticsMenu()) }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)
        
        window.contentViewController = viewController
    }
    
    private let viewController = ViewController<CodeFolderView>()
}
