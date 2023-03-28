import SwiftUI
import SwiftyToolz

@MainActor
struct TestingDashboard: Scene
{
    var body: some Scene
    {
        Window("Testing Dashboard", id: Self.id)
        {
            HSplitView
            {
                List
                {
                    LargeButton("Log App Store Transactions")
                    {
                        AppStoreClient.shared.debugLogAllTransactions()
                    }
                    .padding(.bottom)
                    
                    LargeButton("Log Window States")
                    {
                        NSApp.debugLogWindows()
                    }
                    .padding(.bottom)
                    
                    LargeButton("Log Bundle Infos")
                    {
                        Bundle.main.debugLogInfos()
                    }
                }
                .frame(minWidth: 100, maxWidth: 350)
                .listStyle(.sidebar)
                
                LogView()
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    static let id = "testing-dashboard"
}
