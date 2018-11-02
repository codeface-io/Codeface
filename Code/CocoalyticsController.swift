import UIToolz

class CocoalyticsController: AppController, NSWindowDelegate
{
    func applicationWillBecomeActive(_ notification: Notification)
    {
        window.delegate = self
        window.show()
    }
    
    private lazy var window = Window()
}
