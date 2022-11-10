import Foundation

@objc protocol XPCExecutableClientExportedInterface
{
    func executableDidSend(stdOut: Data,
                           confirmCall: @escaping () -> Void)
}
