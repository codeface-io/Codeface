import SwiftyToolz

extension AppStoreClient
{
    func purchaseSubscriptionLevel1()
    {
        Task
        {
            do
            {
                try await purchase(product: .subscriptionLevel1)
            }
            catch
            {
                log(error.readable)
            }
        }
    }
    
    func forceRestorePurchasedProducts()
    {
        Task
        {
            do
            {
                try await forceRestoreOwnedProducts()
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
