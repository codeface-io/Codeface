import UIToolz
import SwiftObserver

class CocoalyticsController: AppController, NSWindowDelegate
{
    init()
    {
        Log.prefix = "COCOALYTICS"
        
        super.init(withMainMenu: CocoalyticsMenu())
    }
    
    func applicationWillBecomeActive(_ notification: Notification)
    {
        window.delegate = self
        window.show()
    }
    
    private lazy var window = Window(viewController: viewController)
    
    private let viewController = ViewController<CocoalyticsView>()
}
