import Foundation

@objc protocol XPCExecutableClientExportedInterface
{
    func receiveEventFromService(dummyEvent: String,
                                 with reply: @escaping (String) -> Void)
}
