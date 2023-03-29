import SwiftUI
import SwiftyToolz

struct SubscriptionMenu: View
{
    var body: some View
    {
        Menu("Subscription")
        {
            Button("\(displayOptions.showsSubscriptionPanel ? "Hide" : "Show") the Subscription Panel")
            {
                displayOptions.showsSubscriptionPanel.toggle()
            }
            
            Divider()
            
            Button("Subscribe ...")
            {
                Task
                {
                    do
                    {
                        try await appStoreClient.purchase(.subscriptionLevel1)
                    }
                    catch
                    {
                        log(error: error.localizedDescription)
                    }
                }
            }
            .disabled(appStoreClient.ownsProducts)
            
            Button("Restore a Subscription ...")
            {
                Task
                {
                    await appStoreClient.forceRestoreOwnedProducts()
                }
            }
            .disabled(appStoreClient.ownsProducts)
            
            Divider()
            
            Button("Vote On New Features (Subscribers Only) ...")
            {
                openURL(.featureVote)
            }
            .disabled(!appStoreClient.ownsProducts)
            
            Button("Refund a Subscription ...")
            {
                Task
                {
                    do
                    {
                        try await appStoreClient.requestRefund(for: .subscriptionLevel1)
                    }
                    catch
                    {
                        log(error: error.localizedDescription)
                    }
                }
            }
            .disabled(!appStoreClient.ownsProducts)
        }
    }
    
    @ObservedObject var displayOptions: DocumentWindowDisplayOptions
    @ObservedObject var appStoreClient = AppStoreClient.shared
    @Environment(\.openURL) var openURL
}
