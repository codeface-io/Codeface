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
                    Section("Log Current State")
                    {
                        Button {
                            AppStoreClient.shared.debugLogAllTransactions()
                        } label: {
                            Label("App Store Transactions",
                                  systemImage: "icloud")
                            .lineLimit(1)
                        }
                        .buttonStyle(.link)
                        
                        Button {
                            NSApp.debugLogWindows()
                        } label: {
                            Label("Windows",
                                  systemImage: "macwindow")
                            .lineLimit(1)
                        }
                        .buttonStyle(.link)
                        
                        Button {
                            Bundle.main.debugLogInfos()
                        } label: {
                            Label("Main Bundle",
                                  systemImage: "shippingbox")
                            .lineLimit(1)
                        }
                        .buttonStyle(.link)
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
