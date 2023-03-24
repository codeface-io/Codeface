import SwiftyToolz

extension AppStoreClient
{
    func purchaseSubscriptionLevel1() async
    {
        await tryAwaitLog
        {
            try await self.purchase(.subscriptionLevel1)
        }
    }
    
    func refundSubscriptionLevel1() async
    {
        await tryAwaitLog
        {
            try await self.requestRefund(for: .subscriptionLevel1)
        }
    }
    
    func forceRestorePurchasedProducts() async
    {
        await tryAwaitLog
        {
            try await self.forceRestoreOwnedProducts()
        }
    }
}

extension AppStoreClient.ProductID
{
    static let subscriptionLevel1 = Self("io.codeface.subscription.level1")
}
