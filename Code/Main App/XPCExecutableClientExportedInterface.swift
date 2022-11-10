import Foundation

@objc protocol XPCExecutableClientExportedInterface
{
    func executableDidSend(stdOut: Data,
                           confirmCall: @escaping () -> Void)
    
    func executableDidSend(stdErr: Data,
                           confirmCall: @escaping () -> Void)
    
    func executableDidTerminate(confirmCall: @escaping () -> Void)
}
