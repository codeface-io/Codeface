import StoreKit
import SwiftUI
import SwiftyToolz

struct SubscriptionManagementView: View
{
    var body: some View
    {
        let userIsSubscribed = appStoreClient.owns(subscription)
        
        Text(subscription.displayName)
            .font(.title)
            .fontWeight(.bold)
            .padding(.bottom, 6)
        
        Text(subscription.description)
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.bottom)
        
        let green = Color(.systemGreen)
        
        if userIsSubscribed
        {
            HStack
            {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(green)
                
                Text("Subscribed")
            }
            .font(.title3)
            .fontWeight(.medium)
        }
        else
        {
            Text(subscription.displayPrice + " / month")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(green)
        }
        
        Spacer()
        
        if userIsSubscribed
        {
            LargeButton("Vote on New Features", colorScheme: .green)
            {
                openURL(.featureVote)
            }
        }
        else
        {
            LargeButton("Subscribe", colorScheme: .accent)
            {
                do
                {
                    try await appStoreClient.purchase(subscription)
                }
                catch
                {
                    log(error: error.localizedDescription)
                }
            }
        }
    }
    
    let subscription: Product
    @ObservedObject private var appStoreClient = AppStoreClient.shared
    @Environment(\.openURL) var openURL
}
