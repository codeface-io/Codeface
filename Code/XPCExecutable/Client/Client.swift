import FoundationToolz
import Foundation
import Combine
import SwiftyToolz

extension XPCExecutable
{
    class Client: NSObject, XPCExecutableClientExportedInterface
    {
        // MARK: - Respond to Service (XPCExecutableClientExportedInterface)
        
        func executableDidSend(stdOut: Data,
                               confirmCall: @escaping () -> Void)
        {
            confirmCall()
            
            log("received stdout from service: " + (stdOut.utf8String ?? "decoding error"))
        }
        
        func executableDidSend(stdErr: Data,
                               confirmCall: @escaping () -> Void)
        {
            confirmCall()
            
            guard stdErr.count > 0, var stdErrString = stdErr.utf8String else
            {
                log(error: "Executable sent empty or undecodable data via stdErr")
                return
            }
            
            if stdErrString.last == "\n" { stdErrString.removeLast() }
            
            log("executable sent data via stdErr:\n\(stdErrString)")
        }
        
        func executableDidTerminate(confirmCall: @escaping () -> Void)
        {
            log("executable did terminate")
            
            confirmCall()
        }
        
        // MARK: - Basics, Including Exposed Service Proxy
        
        init(serviceBundleID: String) throws
        {
            /**
             "the main application and the helper have an instance of NSXPCConnection. The main application creates its connection object itself, which causes the helper to launch."
             
             https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html#//apple_ref/doc/uid/10000172i-SW6-SW19
             */
            
            connection = NSXPCConnection(serviceName: serviceBundleID)
            connection.remoteObjectInterface = NSXPCInterface(with: XPCExecutableServiceExportedInterface.self)
            
            serviceProxy = try (connection.remoteObjectProxy as? XPCExecutableServiceExportedInterface).unwrap()
            
            super.init()
            
            /// If you want to allow the helper process to call methods on an object in your application, you must set the exportedInterface and exportedObject properties before calling resume.
            connection.exportedInterface = NSXPCInterface(with: XPCExecutableClientExportedInterface.self)
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
        
        deinit
        {
            /// And, when you are finished with the service, clean up the connection like this:
            connection.invalidate()
        }
        
        /// the service proxy is part of the API of this client class. users of the client class call the service via this proxy.
        let serviceProxy: XPCExecutableServiceExportedInterface
        
        private let connection: NSXPCConnection
    }
}
