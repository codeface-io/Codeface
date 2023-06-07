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
    
    func forceRestoreOwnedProducts() async
    {
        do
        {
            try await AppStore.sync()
        }
        catch
        {
            log(warning: "Could not restore products because of this \"error\", which might just indicate the user cancelled the process: " + error.localizedDescription)
            return
        }
        
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
                try await validate(currentEntitlement: transaction)
                
                updatedOwnedProducts += ProductID(transaction.productID)
            }
            catch
            {
                log(error: error.localizedDescription)
            }
        }
        
        log(verbose: "found \(updatedOwnedProducts.count) currently owned products")
        
        ownedProducts = updatedOwnedProducts
    }
    
    private func validate(currentEntitlement transaction: Transaction) async throws
    {
        if transaction.isRevoked
        {
            throw "`currentEntitlements` contains a revoked transaction! this should never happen according to Apple's documentation"
        }
        
        if transaction.isExpired
        {
            log(warning: "`currentEntitlements` contains an expired transaction. According to documentation this must be a subscription in the grace period. gonna check the actual subscription status of the transaction ...")
            
            // we better check the actual status, for it might be in a grace period or somethin ...
            let product = try await fetch(product: .init(transaction.productID))
            
            guard let subInfo = product.subscription else
            {
                throw "the expired transaction has no subscription info. this should never happen since only subscriptions can expire"
            }
            
            let subscriptionGroupStatuses = try await subInfo.status
            
            let subGroupStatusesString = subscriptionGroupStatuses
                .map { $0.state.localizedDescription }
                .joined(separator: ", ")
            
            if subscriptionGroupStatuses.first(where: { $0.subscriptionIsEntitledToService }) == nil
            {
                throw "a so called 'current entitlement' is actually an expired subscription with these states (none of which currently entitles to service): " + subGroupStatusesString
            }
            else
            {
                log(warning: "the expired subscription has these states – at least one of which does indeed entitle to service (but then why is it expired??): " + subGroupStatusesString)
            }
        }
    }
    
    func purchase(_ productID: ProductID) async throws
    {
        
        let product = try await retrieveProduct(for: productID)
        try await purchase(product)
    }
    
    func purchase(_ product: Product) async throws
    {
        // FIXME: why the fuck this warning?? the function is not assigned to any actor. why is there a concurrency context switch involved?
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult
        {
        case .success(let verificationResult):
            /// the signed transaction contains the JWS (JSON web signature)
            let transaction = try verificationResult.payloadValue
            log("✨ user purchased product: " + product.displayName)
            ownedProducts += ProductID(transaction.productID)
            await transaction.finish()
            
        case .userCancelled:
            log("🔙 user cancelled the purchase process for product: " + product.displayName)
            break
            
        case .pending:
            log("⏳ a purchase process is pending for product: " + product.displayName)
            break
            
        @unknown default:
            throw "Unknown purchase result type"
        }
    }
    
    func owns(_ product: Product) -> Bool
    {
        owns(product: .init(product.id))
    }
    
    func owns(product productID: ProductID) -> Bool
    {
        ownedProducts.contains(productID)
    }
    
    var ownsProducts: Bool
    {
        !ownedProducts.isEmpty
    }
    
    @Published private(set) var ownedProducts = Set<ProductID>()
    
    func debugLogAllTransactions()
    {
        Task
        {
            var lines = [String]()
            
            for await verificationResult in Transaction.all
            {
                do
                {
                    let transaction = try verificationResult.payloadValue
                    
                    lines +=
                    "ID: \(transaction.productID) Purchased: \(transaction.purchaseDate.formatted()) Expires: \(transaction.expirationDate?.formatted() ?? "Never")"
                }
                catch
                {
                    log(error.localizedDescription)
                }
            }
            
            if lines.count == 0
            {
                log("Found no verified App Store transactions")
            }
            else
            {
                log(lines.joined(separator: "\n"))
            }
        }
    }
    
    // MARK: - Fetch and Manage Available Products
    
    /// Fetch the product if it hasn't been fetched already
    func retrieveProduct(for productID: ProductID) async throws -> Product
    {
        if let cachedProduct = fetchedProducts[productID]
        {
            return cachedProduct
        }
        else
        {
            return try await fetch(product: productID)
        }
    }
    
    @discardableResult
    func fetch(product productID: ProductID) async throws -> Product
    {
        let products = try await fetch(products: [productID])
        
        guard let product = products.first else
        {
            throw "No product found with ID '\(productID)' (check App Store Connect)"
        }
        
        return product
    }
    
    @discardableResult
    func fetch(products productIDs: [ProductID]) async throws -> [Product]
    {
        let productIDStrings = productIDs.map { $0.string }

        let newlyFetchedProducts = try await Product.products(for: productIDStrings)
        
        for newlyFetchedProduct in newlyFetchedProducts
        {
            fetchedProducts[ProductID(newlyFetchedProduct.id)] = newlyFetchedProduct
        }
        
        return newlyFetchedProducts
    }
    
    @Published var fetchedProducts = [ProductID: Product]()
    
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
            return Date.now >= expirationDate
        }
        
        return false
    }
}
