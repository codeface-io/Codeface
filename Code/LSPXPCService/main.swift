import Foundation

class ListenerDelegate: NSObject, NSXPCListenerDelegate {
    
    /// The helper receives a connection request when the first actual message is sent. The (main app's) connection object’s resume method does not cause a message to be sent.

    /// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        // Configure the connection.
        // First, set the interface that the exported object implements.
        newConnection.exportedInterface = NSXPCInterface(with: LSPXPCServiceProtocol.self)
        
        // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
        let exportedObject = LSPXPCService()
        newConnection.exportedObject = exportedObject
        
        /**
         called when the process on the other end of the connection has crashed or has otherwise closed its connection.

         The local connection object is typically still valid—any future call will automatically spawn a new helper instance unless it is impossible to do so—but you may need to reset any state that the helper would otherwise have kept.

         The handler is invoked on the same queue as reply messages and other handlers, and it is always executed after any other messages or reply block handlers (except for the invalidation handler). It is safe to make new requests on the connection from an interruption handler.
         */
        newConnection.interruptionHandler = {  }
        
        /**
         called when the invalidate method is called or when an XPC helper could not be started. When this handler is called, the local connection object is no longer valid and must be recreated.

         This is always the last handler called on a connection object. When this block is called, the connection object has been torn down. It is not possible to send further messages on the connection at that point, whether inside the handler or elsewhere in your code.
         */
        newConnection.invalidationHandler = {  }
        
        // Resuming the connection allows the system to deliver more incoming messages.
        newConnection.resume()
        
        // Returning true from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call invalidate() on the connection and return false.
        return true
    }
}

// Create the delegate for the service.
let listenerDelegate = ListenerDelegate()

// Set up the one NSXPCListener for this service. It will handle all incoming connections.
let listener = NSXPCListener.service()
listener.delegate = listenerDelegate

// Resuming the serviceListener starts this service. This method does not return.
listener.resume()
