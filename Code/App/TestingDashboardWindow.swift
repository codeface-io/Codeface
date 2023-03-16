import SwiftUI

@MainActor
enum TestingDashboardWindow
{
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
