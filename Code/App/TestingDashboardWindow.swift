import SwiftUI
import SwiftyToolz

@MainActor
enum TestingDashboardWindow
{
    static func closeIfOpen()
    {
        if let testingDashboardWindow = NSApp.window(forID: id)
        {
            log("🪟 gonna close testing dashboard window")
            testingDashboardWindow.close()
        }
    }
    
    static func make() -> some Scene
    {
        Window("Testing Dashboard", id: Self.id)
        {
            HStack
            {
                VStack
                {
                    Button("Log App Store Transactions")
                    {
                        AppStoreClient.shared.debugLogAllTransactions()
                    }
                    .padding()
                    
                    Spacer()
                }
                
                LogView()
            }
        }
    }
    
    static let id = "testing-dashboard"
}

extension NSApplication
{
    func window(forID id: String) -> NSWindow?
    {
        windows.first { $0.identifier?.rawValue == id }
    }
}
