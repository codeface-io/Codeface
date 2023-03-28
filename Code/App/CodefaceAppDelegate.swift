import SwiftUI
import SwiftyToolz

/// For Window Management On Launch. We have to use the app delegate, because onChange(of: scenePhase) does not work when no window is being opened on launch in the first place ... 🤮
@MainActor class CodefaceAppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        log("app did finish launching")
    }
    
    func applicationDidBecomeActive(_ notification: Notification)
    {
        log("app did become active")
        setupWindowVisibilityOnAppActivation()
    }
    
    // MARK: - Window Management
    
    private func setupWindowVisibilityOnAppActivation()
    {
        Self.openDocumentWindowIfNoneExist()
        
        let isFirstActivationAfterLaunch = !hasBecomeActiveAfterLaunch
        
        if isFirstActivationAfterLaunch
        {
            // we assume that identified windows are auxilliary ones
            NSApp.closeWindows { $0.identifier != nil }
            hasBecomeActiveAfterLaunch = true
        }
    }
    
    private var hasBecomeActiveAfterLaunch = false
    
    private static func openDocumentWindowIfNoneExist()
    {
        if !moreWindowsThanTestingDashboardExist()
        {
            log("🪟 gonna open document window because none exists")
            NSDocumentController.shared.newDocument(nil)
        }
    }
    
    private static func moreWindowsThanTestingDashboardExist() -> Bool
    {
        if NSApp.windows.count > 1 { return true }
        if NSApp.windowExists(withID: TestingDashboard.id) { return false }
        return NSApp.windows.count == 1
    }
}
