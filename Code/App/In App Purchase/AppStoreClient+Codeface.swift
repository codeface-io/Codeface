import SwiftyToolz

extension AppStoreClient
{
    static func purchaseSubscriptionLevel1()
    {
        Task
        {
            do
            {
                try await shared.purchase(.subscriptionLevel1)
            }
            catch
            {
                log(error.readable)
            }
        }
    }
    
    static func forceRestorePurchasedProducts()
    {
        Task
        {
            do
            {
                try await shared.forceRestorePurchasedProducts()
            }
            catch
            {
                log(error.readable)
            }
        }
    }
}

extension AppStoreClient.ProductID
{
    static let subscriptionLevel1 = Self("io.codeface.subscription.level1")
}
