import FoundationToolz
import Foundation
import SwiftLSP
import SwiftyToolz

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class LSPXPCService: NSObject, LSPXPCServiceExportedInterface, NSXPCListenerDelegate
{
    override init()
    {
        super.init()
        
        log("Initializing \(Self.self)")
    }
    
    /// The helper receives a connection request when the first actual message is sent. The (main app's) connection object’s resume method does not cause a message to be sent.

    /// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        // Configure the connection.
        // First, set the interface that the exported object implements.
        newConnection.exportedInterface = NSXPCInterface(with: LSPXPCServiceExportedInterface.self)
        
        // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
        newConnection.exportedObject = self
        
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
        
        activeXPCConnection = newConnection
        
        // Returning true from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call invalidate() on the connection and return false.
        return true
    }
    
    @objc func testLSPServer(someParam: String,
                             with reply: @escaping (String) -> Void)
    {
        log("✅ service called with param: \(someParam)")
        
        let executableConfig = Executable.Configuration(path: "/usr/bin/xcrun",
                                                        arguments: ["sourcekit-lsp"])
        
        do
        {
            let newExecutable = try LSP.ServerExecutable(config: executableConfig)
            {
                lspPacketFromLSPServer in
                
                // TODO: send packet to client
            }
            
            activeExecutable = newExecutable
            
            newExecutable.didSendError =
            {
                stdErrData in
                
                guard stdErrData.count > 0, var stdErrString = stdErrData.utf8String else
                {
                    log(error: "LSP server executable sent empty or undecodable data via stdErr")
                    return
                }
                
                if stdErrString.last == "\n" { stdErrString.removeLast() }
                
                log("LSP server executable sent data via stdErr:\n\(stdErrString)")
                
                // TODO: send stderr data to client
            }
            
            newExecutable.didTerminate =
            {
                log(warning: "LSP server executable did terminate")
                
                // TODO: inform client
            }
            
            newExecutable.run()
            
            log("✅ Initialized LSP.ServerExecutable")
            reply("✅ Initialized LSP.ServerExecutable")
        }
        catch
        {
            log(error: "🛑 " + error.readable.message)
            reply(error.readable.message)
        }
    }
    
    func testCallingClient()
    {
        guard let activeXPCConnection else
        {
            log(warning: "Tried to call client while active XPC connection is nil")
            return
        }
        
        guard let clientProxy = activeXPCConnection.remoteObjectProxy as? LSPXPCClientExportedInterface else
        {
            log(error: "Connection has no proxy object set of type \(LSPXPCClientExportedInterface.self)")
            return
        }

        clientProxy.receiveEventFromService(dummyEvent: "dummy event sent from service")
        {
            clientReply in

            log("✅ client replied: " + clientReply)
        }
    }
    
    func writeToActiveExecutable(_ data: Data)
    {
        guard let activeExecutable else
        {
            log(warning: "Tried to write data to active executable while the latter is nil")
            return
        }
        
        activeExecutable.receive(input: data)
    }
    
    private var activeXPCConnection: NSXPCConnection? = nil
    private var activeExecutable: LSP.ServerExecutable? = nil
}