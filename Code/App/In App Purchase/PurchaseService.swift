import StoreKit
import SwiftyToolz

enum PurchaseService
{
    static func testStoreKit() async
    {
        do
        {
            let productID = "io.codeface.subscription.level1"
            let products = try await Product.products(for: [productID])
            
            for product in products
            {
                print("🥳 " + product.description)
            }
        }
        catch
        {
            log(error.readable)
        }
    }
}
