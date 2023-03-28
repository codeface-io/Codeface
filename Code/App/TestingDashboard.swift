import SwiftUI
import SwiftyToolz

@MainActor
struct TestingDashboard: Scene
{
    var body: some Scene
    {
        Window("Testing Dashboard", id: Self.id)
        {
            HStack
            {
                VStack(spacing: 20)
                {
                    LargeButton("Log App Store Transactions")
                    {
                        AppStoreClient.shared.debugLogAllTransactions()
                    }
                    
                    LargeButton("Log Window States")
                    {
                        NSApp.debugLogWindows()
                    }
                    
                    LargeButton("Log Bundle Infos")
                    {
                        Bundle.main.debugLogInfos()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: 250)
                .padding()
                
                LogView()
            }
        }
    }
    
    static let id = "testing-dashboard"
}
