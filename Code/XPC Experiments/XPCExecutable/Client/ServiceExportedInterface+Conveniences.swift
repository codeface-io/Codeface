import FoundationToolz
import Foundation

extension XPCExecutableServiceExportedInterface
{
    func launchExecutable(_ config: Executable.Configuration,
                          handleCompletion: @escaping (Error?) -> Void)
    {
        // TODO: This should all use async/await, but we need to handle timeouts in case XPC fails, see "Pitfall": https://www.chimehq.com/blog/extensionkit-xpc
        
        do
        {
            let executableConfigData: Data = try config.encode(options: [])
            
            launchExecutable(withEncodedConfig: executableConfigData,
                             handleCompletion: handleCompletion)
        }
        catch
        {
            handleCompletion(error)
        }
    }
}
