import SwiftUI
import SwiftyToolz

/// For Window Management On Launch. We have to use the app delegate, because onChange(of: scenePhase) does not work when no window is being opened on launch in the first place ... 🤮
@MainActor class CodefaceAppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        log(verbose: "app did finish launching")
    }
    
    func applicationDidBecomeActive(_ notification: Notification)
    {
        log(verbose: "app did become active")
        
        if didJustLaunch
        {
            Self.closeAuxilliaryWindows()
            didJustLaunch = false
        }
        
        Self.openDocumentWindowIfNoneExist()
    }
    
    private var didJustLaunch = true
    
    // MARK: - Window Management
    
    private static func closeAuxilliaryWindows()
    {
        // we assume that identified windows are auxilliary ones
        NSApp.closeWindows { $0.identifier != nil }
    }
    
    private static func openDocumentWindowIfNoneExist()
    {
        if !unidentifiedWindowsExist()
        {
            log("🪟 gonna open document window because none exists")
            NSDocumentController.shared.newDocument(self)
        }
    }
    
    private static func unidentifiedWindowsExist() -> Bool
    {
        NSApp.windows.first { $0.identifier == nil } != nil
    }
}
