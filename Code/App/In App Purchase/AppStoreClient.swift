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
        /**
         `currentEntitlements` "returns transactions that the customer **may be** entitled to" https://developer.apple.com/videos/play/wwdc2022/110404/
         
         But that's just for 2 reasons: 1) non-renewable subs require their own logic to determine when and how long they're valid and 2) app logic might withhold products for whatever other reasons and only offer certain product IDs ...
         */
        
        var transactions = [Transaction]()
        
        for await verificationResult in Transaction.currentEntitlements
        {
            do
            {
                transactions += try verificationResult.payloadValue
            }
            catch
            {
                log(error: error.localizedDescription)
            }
        }
        
        var updatedOwnedProducts = Set<ProductID>()
        
        for transaction in transactions
        {
            log("found transaction of owned product: \(transaction.productID) (expriation date: \(transaction.expirationDate?.formatted() ?? "none"))")
            
            do
            {
                // FIXME: for whatever reason, current entitlements sometimes returns expired subscription on app launch, at least during Xcode testing (wtf apple? 🤮). to be sure, we check all kind of stuff in here ...
                try await Self.validate(currentEntitlement: transaction)
                
                updatedOwnedProducts += ProductID(transaction.productID)
            }
            catch
            {
                log(error: error.localizedDescription)
            }
        }
        
        log("↓ found \(updatedOwnedProducts.count) currently owned products")
        
        ownedProducts = updatedOwnedProducts
    }
    
    private static func validate(currentEntitlement transaction: Transaction) async throws
    {
        if transaction.isRevoked
        {
            throw "`currentEntitlements` contains a revoked transaction! this should never happen according to Apple's documentation"
        }
        
        if transaction.isExpired
        {
            log(warning: "`currentEntitlements` contains and expired transaction. According to documentation this must be a subscription in the grace period. gonna check the actual subscription status of the transaction ...")
            
            // we better check the actual status, for it might be in a grace period or somethin ...
            let product = try await request(product: .init(transaction.productID))
            
            guard let subInfo = product.subscription else
            {
                throw "the expired transaction has no subscription info. this should never happen since only subscriptions can expire"
            }
            
            let subGroupStatuses = try await subInfo.status
            
            let subGroupStatusesString = subGroupStatuses
                .map { $0.state.localizedDescription }
                .joined(separator: ", ")
            
            if subGroupStatuses.first(where: { $0.subscriptionIsEntitledToService }) == nil
            {
                throw "a so called 'current entitlement' is actually an expired subscription with these states (none of which currently entitles to service): " + subGroupStatusesString
            }
            else
            {
                log("the expired subscription has these states (at least one does indeed entitle to service): " + subGroupStatusesString)
            }
        }
    }
    
    func purchase(_ productID: ProductID) async throws
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

extension Transaction
{
    var isRevoked: Bool
    {
        revocationReason != nil
    }
    
    var isExpired: Bool
    {
        if let expirationDate
        {
            return Date() >= expirationDate
        }
        
        return false
    }
}
