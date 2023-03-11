import SwiftyToolz

extension AppStore
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
}

extension AppStore.ProductID
{
    static let subscriptionLevel1 = Self("io.codeface.subscription.level1")
}
