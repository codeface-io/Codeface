import UIToolz

class CocoalyticsController: AppController, NSWindowDelegate
{
    init() { super.init(withMainMenu: Menu()) }
    
    func applicationWillBecomeActive(_ notification: Notification)
    {
        window.delegate = self
        window.show()
    }
    
    private lazy var window = Window(viewController: viewController)
    
    private let viewController = ViewControlller<MainView>()
}
