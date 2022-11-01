import Foundation
import SwiftyToolz

func experiment()
{
    /**
     "the main application and the helper have an instance of NSXPCConnection. The main application creates its connection object itself, which causes the helper to launch."
     
     https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html#//apple_ref/doc/uid/10000172i-SW6-SW19
     */
    
    /// To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:
    
    let connectionToService = NSXPCConnection(serviceName: "com.flowtoolz.codeface.LSPXPCService")
    connectionToService.remoteObjectInterface = NSXPCInterface(with: LSPXPCServiceProtocol.self)
    
    /**
     called when the process on the other end of the connection has crashed or has otherwise closed its connection.

     The local connection object is typically still valid—any future call will automatically spawn a new helper instance unless it is impossible to do so—but you may need to reset any state that the helper would otherwise have kept.

     The handler is invoked on the same queue as reply messages and other handlers, and it is always executed after any other messages or reply block handlers (except for the invalidation handler). It is safe to make new requests on the connection from an interruption handler.
     */
    connectionToService.interruptionHandler = {  }
    
    /**
     called when the invalidate method is called or when an XPC helper could not be started. When this handler is called, the local connection object is no longer valid and must be recreated.

     This is always the last handler called on a connection object. When this block is called, the connection object has been torn down. It is not possible to send further messages on the connection at that point, whether inside the handler or elsewhere in your code.
     */
    connectionToService.invalidationHandler = {  }
    
    /// If you want to allow the helper process to call methods on an object in your application, you must set the exportedInterface and exportedObject properties before calling resume.
    
    connectionToService.resume()
    
    /// Once you have a connection to the service, you can use it like this:
    
    if let proxy = connectionToService.remoteObjectProxy as? LSPXPCServiceProtocol {
        proxy.uppercase(string: "hello") { aString in
            log("Result string was: \(aString)")
        }
    }
    
    /// And, when you are finished with the service, clean up the connection like this:
    
    connectionToService.invalidate()
}
