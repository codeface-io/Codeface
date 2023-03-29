import SwiftUI
import SwiftyToolz

@MainActor
struct TestingDashboard: Scene
{
    var body: some Scene
    {
        Window("Testing Dashboard", id: Self.id)
        {
            NavigationSplitView
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
                .listStyle(.sidebar)
            }
            detail:
            {
                LogView()
            }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
    }
    
    static let id = "testing-dashboard"
}
