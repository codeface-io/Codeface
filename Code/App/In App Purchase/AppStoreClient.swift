import StoreKit
import SwiftyToolz

@MainActor
class AppStoreClient: ObservableObject
{
    // MARK: - Life Cycle
    
    static let shared = AppStoreClient()
    
    private init()
    {
        Task { await AppStoreClient.shared.updatePurchasedProducts() }
    }
    
    deinit
    {
        transactionObserver.cancel()
        subscriptionStatusObserver.cancel()
    }
    
    // MARK: - Purchased Products
    
    func purchase(_ productID: ProductID) async throws
    {
        let product = try await Self.request(productID)
        
        // FIXME: why the fuck this warning?? the function is not assigned to any actor. why is there a concurrency context switch involved?
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult
        {
        case .success(let verificationResult):
            /// the signed transaction contains the JWS (JSON web signature)
            let transaction = try verificationResult.payloadValue
            purchasedProducts += productID
            await transaction.finish()
            
        case .userCancelled, .pending:
            #if DEBUG
            purchasedProducts += productID // for testing
            #else
            break
            #endif
            
        @unknown default:
            throw "Unknown purchase result type"
        }
    }
    
    private let transactionObserver = Task
    {
        for await verificationResult in Transaction.updates
        {
            do
            {
                let transaction = try verificationResult.payloadValue
                
                let productID = ProductID(transaction.productID)
                
                if transaction.revocationReason == nil
                {
                    AppStoreClient.shared.purchasedProducts += productID
                    await transaction.finish()
                }
                else
                {
                    /// TODO: Is this the proper way to detect revocation? or is it sufficient to observe the `Product.SubscriptionInfo.Status.updates` ? also: we know this transaction is revoked, but we don't know that this is what was updated on it ...
                    AppStoreClient.shared.purchasedProducts -= productID
                }                
            }
            catch
            {
                log(error.readable)
            }
        }
    }
    
    private let subscriptionStatusObserver = Task
    {
        for await subscriptionStatus in Product.SubscriptionInfo.Status.updates
        {
            let subIsActive = subscriptionStatus.subscriptionIsEntitledToService
            
            do
            {
                let latestTransaction = try subscriptionStatus.transaction.payloadValue
                let productID = ProductID(latestTransaction.productID)
                
                if subIsActive // just to be sure, maybe it was renewed or completed
                {
                    AppStoreClient.shared.purchasedProducts += productID
                }
                else // detected an expiry / cancellation
                {
                    AppStoreClient.shared.purchasedProducts -= productID
                }
            }
            catch
            {
                log(warning: "Subscription status updated based on an unverified subscription, so we're gonna ignore the update. verification error: " + error.localizedDescription)
            }
        }
    }
    
    func forceRestorePurchasedProducts() async throws
    {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    func updatePurchasedProducts() async
    {
        var updatedPurchasedProducts = Set<ProductID>()

        for await verificationResult in Transaction.currentEntitlements
        {
            do
            {
                let transaction = try verificationResult.payloadValue
                updatedPurchasedProducts += ProductID(transaction.productID)
            }
            catch
            {
                log(error.readable)
            }
        }
        
        purchasedProducts = updatedPurchasedProducts
    }
    
    @Published private(set) var purchasedProducts = Set<ProductID>()
    
    // MARK: - Available Products
    
    static func request(_ productID: ProductID) async throws -> Product
    {
        let products = try await Product.products(for: [productID.string])
        
        guard let product = products.first else
        {
            throw "No product found with ID '\(productID)' (check App Store Connect)"
        }
        
        return product
    }
    
    struct ProductID: Hashable, Sendable
    {
        init(_ string: String) { self.string = string }
        
        let string: String
    }
}

//extension VerificationResult
//{
//    var payloadValueUnverified: SignedType
//    {
//        switch self
//        {
//        case .verified(let value): return value
//        case .unverified(let value, _): return value
//        }
//    }
//}

extension Product.SubscriptionInfo.Status
{
    var subscriptionIsEntitledToService: Bool
    {
        state == .subscribed || state == .inGracePeriod
    }
}

