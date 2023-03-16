import StoreKit
import SwiftyToolz

@MainActor
class AppStoreClient: ObservableObject
{
    // MARK: - Life Cycle
    
    static let shared = AppStoreClient()
    
    private init()
    {
        transactionObserver = makeTransactionObserver()
        subscriptionStatusObserver = makeSubscriptionStatusObserver()
        
        Task { await updateOwnedProducts() }
    }
    
    deinit
    {
        transactionObserver?.cancel()
        subscriptionStatusObserver?.cancel()
    }
    
    // MARK: - Observe App Store
    
    private var transactionObserver: Task<Void, Never>? = nil
    
    private func makeTransactionObserver() -> Task<Void, Never>
    {
        Task.detached
        {
            for await verificationResult in Transaction.updates
            {
                log("↔️ transaction update")
                
                do
                {
                    let transaction = try verificationResult.payloadValue
                    await self.updateOwnedProducts()
                    await transaction.finish()
                }
                catch
                {
                    log(error.readable)
                }
            }
            
            log(error: "We should never reach the end of this observation task")
        }
    }
    
    private var subscriptionStatusObserver: Task<Void, Never>? = nil
    
    private func makeSubscriptionStatusObserver() -> Task<Void, Never>
    {
        Task.detached
        {
            for await updatedSubscriptionStatus in SubscriptionStatus.updates
            {
                do
                {
                    try await self.didReceive(updatedSubscriptionStatus)
                }
                catch
                {
                    log(error.readable)
                }
            }
            
            log(error: "We should never reach the end of this observation task")
        }
    }
    
    private func didReceive(_ updatedSubscriptionStatus: SubscriptionStatus) async throws
    {
        let renewalInfo = try updatedSubscriptionStatus.renewalInfo.payloadValue
        
        log("↻ subscription status update: \(updatedSubscriptionStatus.state.localizedDescription) (will renew: \(renewalInfo.willAutoRenew))")
        
        let latestTransaction = try updatedSubscriptionStatus.transaction.payloadValue
        let productID = ProductID(latestTransaction.productID)
        
        if !updatedSubscriptionStatus.subscriptionIsEntitledToService
        {
            log("💀 subscription ended")
            ownedProducts -= productID
        }
        else
        {
            log("🐣 subscription (re-)started")
            ownedProducts += productID
        }
    }
    
    typealias SubscriptionStatus = Product.SubscriptionInfo.Status
    
    // MARK: - Manage Owned Products
    
    func forceRestoreOwnedProducts() async throws
    {
        try await AppStore.sync()
        await updateOwnedProducts()
    }
    
    func updateOwnedProducts() async
    {
        var updatedOwnedProducts = Set<ProductID>()
        
        for await verificationResult in Transaction.currentEntitlements
        {
            do
            {
                let transaction = try verificationResult.payloadValue
                
                log("found transaction of owned product: \(transaction.productID)")
                
                updatedOwnedProducts += ProductID(transaction.productID)
            }
            catch
            {
                log(error.readable)
            }
        }
        
        log("↓ found \(updatedOwnedProducts.count) currently owned products")
        
        ownedProducts = updatedOwnedProducts
    }
    
    func purchase(product productID: ProductID) async throws
    {
        let product = try await Self.request(product: productID)
        try await purchase(product)
    }
    
    func purchase(_ product: Product) async throws
    {
        // FIXME: why the fuck this warning?? the function is not assigned to any actor. why is there a concurrency context switch involved?
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult
        {
        case .success(let verificationResult):
            log("✨ purchase success")
            /// the signed transaction contains the JWS (JSON web signature)
            let transaction = try verificationResult.payloadValue
            ownedProducts += ProductID(transaction.productID)
            await transaction.finish()
            
        case .userCancelled:
            log("❌ purchase cancelled")
            break
            
        case .pending:
            log("⏳ purchase pending")
            break
            
        @unknown default:
            throw "Unknown purchase result type"
        }
    }
    
    @Published private(set) var ownedProducts = Set<ProductID>()
    
    func debugLogAllTransactions()
    {
        Task
        {
            for await verificationResult in Transaction.all
            {
                do
                {
                    let transaction = try verificationResult.payloadValue
                    
                    log("Purchased: \(transaction.purchaseDate.formatted()) Expires: \(transaction.expirationDate?.formatted() ?? "Never")")
                }
                catch
                {
                    log(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Request Available Products
    
    static func request(product productID: ProductID) async throws -> Product
    {
        let products = try await request(products: [productID])
        
        guard let product = products.first else
        {
            throw "No product found with ID '\(productID)' (check App Store Connect)"
        }
        
        return product
    }
    
    static func request(products productIDs: [ProductID]) async throws -> [Product]
    {
        try await Product.products(for: productIDs.map({ $0.string }))
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
