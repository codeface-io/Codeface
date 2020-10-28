import UIToolz
import AppKit
import SwiftyToolz

import SwiftObserver

@main
class CodefaceAppController: AppController
{
    static func main() { instance.startApp() }
    
    private static let instance = CodefaceAppController(appView: AnalyticsView(),
                                                        appMenu: CodefaceMenu())
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)

        do { try Loading.loadLastOpenFolder() }
        catch { log(error) }
    }
}
