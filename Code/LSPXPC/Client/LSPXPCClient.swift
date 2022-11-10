import FoundationToolz
import Foundation
import Combine
import SwiftyToolz

class LSPXPCClient: NSObject, LSPXPCClientExportedInterface
{
    override init()
    {
        super.init()
        
        /**
         "the main application and the helper have an instance of NSXPCConnection. The main application creates its connection object itself, which causes the helper to launch."
         
         https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html#//apple_ref/doc/uid/10000172i-SW6-SW19
         */
        
        /// To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:
        
        connection.remoteObjectInterface = NSXPCInterface(with: LSPXPCServiceExportedInterface.self)
        
        /// If you want to allow the helper process to call methods on an object in your application, you must set the exportedInterface and exportedObject properties before calling resume.
        connection.exportedInterface = NSXPCInterface(with: LSPXPCClientExportedInterface.self)
        connection.exportedObject = self
        
        /**
         called when the process on the other end of the connection has crashed or has otherwise closed its connection.
         
         The local connection object is typically still valid—any future call will automatically spawn a new helper instance unless it is impossible to do so—but you may need to reset any state that the helper would otherwise have kept.
         
         The handler is invoked on the same queue as reply messages and other handlers, and it is always executed after any other messages or reply block handlers (except for the invalidation handler). It is safe to make new requests on the connection from an interruption handler.
         */
        connection.interruptionHandler = {  }
        
        /**
         called when the invalidate method is called or when an XPC helper could not be started. When this handler is called, the local connection object is no longer valid and must be recreated.
         
         This is always the last handler called on a connection object. When this block is called, the connection object has been torn down. It is not possible to send further messages on the connection at that point, whether inside the handler or elsewhere in your code.
         */
        connection.invalidationHandler = {  }
        
        connection.activate()
    }
    
    func callServiceExample()
    {
        /// Once you have a connection to the service, you can use it like this:
        
        guard let serviceProxy = connection.remoteObjectProxy as? LSPXPCServiceExportedInterface else
        {
            log(error: "Connection has no proxy object set of type \(LSPXPCServiceExportedInterface.self)")
            return
        }
        
        let executableConfig = Executable.Configuration(path: "/usr/bin/xcrun",
                                                        arguments: ["sourcekit-lsp"])
        
        do
        {
            let executableConfigData: Data = try executableConfig.encode(options: [])
            
            serviceProxy.launchExecutable(withEncodedConfig: executableConfigData)
            {
                serviceReply in
                
                log("✅ service replied: " + serviceReply)
            }
        }
        catch
        {
            log(error.readable)
        }
    }
    
    deinit
    {
        /// And, when you are finished with the service, clean up the connection like this:
        connection.invalidate()
    }
    
    func receiveEventFromService(dummyEvent: String,
                                 with reply: @escaping (String) -> Void)
    {
        log("received event from service: " + dummyEvent)
        
        reply("ok")
    }
    
    private let connection = NSXPCConnection(serviceName: serviceBundleID)
    
    private static let serviceBundleID = "com.flowtoolz.codeface.LSPXPCService"
}
