import StoreKit
import SwiftyToolz

class AppStore: ObservableObject
{
    static let shared = AppStore()
    
    private init() {}
    
//    static func bla() async
//    {
//        for await verificationResult in Transaction.updates
//        {
//            do
//            {
//                let transaction = try verificationResult.payloadValue
//            }
//            catch
//            {
//                log(error.readable)
//            }
//        }
//    }
    
    func purchase(_ productID: ProductID) async throws
    {
        let product = try await Self.request(productID)
        
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult
        {
        case .success(let verificationResult):
            /// the signed transaction contains the JWS (JSON web signature)
            let transaction = try verificationResult.payloadValue
            add(purchase: productID)
            await transaction.finish()
            
        case .userCancelled, .pending:
            #if DEBUG
            add(purchase: productID) // for testing
            #endif
            
        @unknown default:
            throw "Unknown purchase result type"
        }
    }
    
    private func add(purchase: ProductID)
    {
        purchasedProducts += purchase
    }
    
    @Published private(set) var purchasedProducts = Set<ProductID>()
    
    static func request(_ productID: ProductID) async throws -> Product
    {
        let products = try await Product.products(for: [productID.string])
        
        guard let product = products.first else
        {
            throw "No product found with ID '\(productID)' (check App Store Connect)"
        }
        
        return product
    }
}

struct ProductID: Hashable
{
    init(_ string: String) { self.string = string }
    
    let string: String
}
