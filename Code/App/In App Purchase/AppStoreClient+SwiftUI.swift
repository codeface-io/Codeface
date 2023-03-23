import SwiftUI
import StoreKit
import SwiftyToolz

extension AppStoreClient
{
    /// The request being successful does **not** mean it has been approved
    func requestRefund(for productID: ProductID) async throws
    {
        guard let verificationResult = await StoreKit.Transaction.latest(for: productID.string) else
        {
            throw "Tried to request a refund for a product the user never bought: " + productID.string
        }
        
        let transaction = try verificationResult.payloadValue
        
        try await requestRefund(for: transaction)
    }
    
    /// The request being successful does **not** mean it has been approved
    func requestRefund(for transaction: StoreKit.Transaction) async throws
    {
        let presentRefundSheet = StoreKit.Transaction.beginRefundRequest(transaction)
        let presenter = try Self.retrievePresentingViewController()
        let requestStatus = try await presentRefundSheet(presenter)
        
        switch requestStatus
        {
        case .success:
            log("Did request refund")
        case .userCancelled:
            log("User did cancel refund request")
        @unknown default:
            throw "Refund request returned unknown status: \(requestStatus)"
        }
    }
    
    private static func retrievePresentingViewController() throws -> NSViewController
    {
        guard let viewController = NSApp.keyWindow?.contentViewController else
        {
            throw "Could not retrieve view controller from key window"
        }
        
        return viewController
    }
}
