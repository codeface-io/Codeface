import SwiftyToolz

extension AppStoreClient
{
    func purchaseSubscriptionLevel1()
    {
        tryLog
        {
            try await self.purchase(.subscriptionLevel1)
        }
    }
    
    func refundSubscriptionLevel1()
    {
        tryLog
        {
            try await self.requestRefund(for: .subscriptionLevel1)
        }
    }
    
    func forceRestorePurchasedProducts()
    {
        tryLog
        {
            try await self.forceRestoreOwnedProducts()
        }
    }
}

extension AppStoreClient.ProductID
{
    static let subscriptionLevel1 = Self("io.codeface.subscription.level1")
}
