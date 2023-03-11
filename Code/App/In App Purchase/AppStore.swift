import StoreKit
import SwiftyToolz

class AppStore: ObservableObject
{
    // MARK: - Life Cycle
    
    static let shared = AppStore()
    
    private init()
    {
        Task { await AppStore.shared.updatePurchasedProducts() }
    }
    
    deinit { transactionObserver.cancel() }
    
    // MARK: - Purchased Products
    
    func purchase(_ productID: ProductID) async throws
    {
        let product = try await Self.request(productID)
        
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
            #endif
            
        @unknown default:
            throw "Unknown purchase result type"
        }
    }
    
    private let transactionObserver = Task.detached
    {
        for await verificationResult in Transaction.updates
        {
            do
            {
                let transaction = try verificationResult.payloadValue
                AppStore.shared.purchasedProducts += ProductID(transaction.productID)
                await transaction.finish()
            }
            catch
            {
                log(error.readable)
            }
        }
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
    
    struct ProductID: Hashable
    {
        init(_ string: String) { self.string = string }
        
        let string: String
    }
}
