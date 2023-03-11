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

extension ProductID
{
    static let subscriptionLevel1 = ProductID("io.codeface.subscription.level1")
}
