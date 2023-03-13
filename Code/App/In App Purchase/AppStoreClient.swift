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
            print("✨ purchase success")
            /// the signed transaction contains the JWS (JSON web signature)
            let transaction = try verificationResult.payloadValue
            purchasedProducts += productID
            await transaction.finish()
            
        case .userCancelled, .pending:
            print("⋯ purchase cancelled or pending")
            break
            
        @unknown default:
            throw "Unknown purchase result type"
        }
    }
    
    private let transactionObserver = Task
    {
        for await verificationResult in Transaction.updates
        {
            print("↔️ transaction update")
            
            do
            {
                let transaction = try verificationResult.payloadValue
                
                let productID = ProductID(transaction.productID)
                
                print("transaction is revoked: \(transaction.revocationReason != nil)")
                
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
            do
            {
                let renewalInfo = try subscriptionStatus.renewalInfo.payloadValue
                
                print("↻ subscription status update: \(subscriptionStatus.state.localizedDescription) (will renew: \(renewalInfo.willAutoRenew))")
                
                if !subscriptionStatus.subscriptionIsEntitledToService
                {
                    print("💀 subscription ended")
                    let latestTransaction = try subscriptionStatus.transaction.payloadValue
                    let productID = ProductID(latestTransaction.productID)
                    AppStoreClient.shared.purchasedProducts -= productID
                }
            }
            catch
            {
                log(error.readable)
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
                
                let productID = ProductID(transaction.productID)
                
                let product = try await Self.request(productID)
                
                if let sub = product.subscription,
                   let status = try await sub.status.first,
                   !status.subscriptionIsEntitledToService
                {
                    print("🤪 'currentEntitlements' contains a subscription that does not entitle to any services 🤮 thanks apple this is impossible to understand, test and develop")
                }
                else
                {
                    updatedPurchasedProducts += productID
                }
            }
            catch
            {
                log(error.readable)
            }
        }
        
        print("↓ downloaded \(updatedPurchasedProducts.count) products")
        
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

extension Product.SubscriptionInfo.Status
{
    var subscriptionIsEntitledToService: Bool
    {
        state == .subscribed || state == .inGracePeriod
    }
}

