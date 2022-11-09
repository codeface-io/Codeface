import Foundation

/// The protocol that this service will vend as its API. This protocol will also need to be visible to the process hosting the service (the main app).
@objc protocol LSPXPCServiceProtocol {
    
    /// Replace the API of this protocol with an API appropriate to the service you are vending.
    func testLSPServer(someParam: String, with reply: @escaping (String) -> Void)
}
