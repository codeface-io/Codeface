import Foundation

@objc protocol LSPXPCClientProtocol
{
    func receiveEventFromService(dummyEvent: String,
                                 with reply: @escaping (String) -> Void)
}
