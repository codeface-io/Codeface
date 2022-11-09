import Foundation

@objc protocol LSPXPCClientExportedInterface
{
    func receiveEventFromService(dummyEvent: String,
                                 with reply: @escaping (String) -> Void)
}
