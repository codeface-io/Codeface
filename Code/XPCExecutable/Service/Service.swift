import FoundationToolz
import Foundation
import SwiftyToolz

extension XPCExecutable
{
    /// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
    class Service: NSObject, XPCExecutableServiceExportedInterface, NSXPCListenerDelegate
    {
        // MARK: - Respond to Client (XPCExecutableServiceExportedInterface)
        
        @objc func launchExecutable(withEncodedConfig executableConfigData: Data,
                                    handleCompletion: @escaping (Error?) -> Void)
        {
            do
            {
                let executableConfig = try Executable.Configuration(jsonData: executableConfigData)
                
                let newExecutable = try Executable(config: executableConfig)
                
                activeExecutable = newExecutable
                
                newExecutable.didSendOutput =
                {
                    [weak self] stdOut in
                    
                    guard let self else { return }
                    
                    do
                    {
                        let clientProxy = try self.getClientProxy()
                        
                        clientProxy.executableDidSend(stdOut: stdOut)
                        {
                            log("✅ client confirmed call")
                        }
                    }
                    catch
                    {
                        log(error.readable)
                    }
                }
                
                newExecutable.didSendError =
                {
                    stdErrData in
                    
                    guard stdErrData.count > 0, var stdErrString = stdErrData.utf8String else
                    {
                        log(error: "Executable sent empty or undecodable data via stdErr")
                        return
                    }
                    
                    if stdErrString.last == "\n" { stdErrString.removeLast() }
                    
                    log("executable sent data via stdErr:\n\(stdErrString)")
                    
                    // TODO: send stderr data to client
                }
                
                newExecutable.didTerminate =
                {
                    log(warning: "Executable did terminate")
                    
                    // TODO: inform client
                }
                
                newExecutable.run()
                
                log("✅ Launched executable: \(executableConfig.path) \(executableConfig.arguments.joined(separator: " "))")
                handleCompletion(nil)
            }
            catch
            {
                log(error.readable)
                handleCompletion(error)
            }
        }
        
        // MARK: - Call Client (using XPCExecutableClientExportedInterface)
        
        private func getClientProxy() throws -> some XPCExecutableClientExportedInterface
        {
            guard let activeXPCConnection else
            {
                throw "Tried to get client proxy while active XPC connection is nil"
            }
            
            guard let clientProxy = activeXPCConnection.remoteObjectProxy as? XPCExecutableClientExportedInterface else
            {
                throw "Connection proxy object is not of type \(XPCExecutableClientExportedInterface.self) but of type \(type(of: activeXPCConnection.remoteObjectProxy))"
            }
                            
            return clientProxy
        }
        
        // MARK: - Manage Active Executable
        
        func writeToActiveExecutable(_ data: Data)
        {
            guard let activeExecutable else
            {
                log(warning: "Tried to write data to active executable while the latter is nil")
                return
            }
            
            activeExecutable.receive(input: data)
        }
        
        private var activeExecutable: Executable? = nil
        
        // MARK: - Basics, including NSXPCConnection
        
        /// The helper receives a connection request when the first actual message is sent. The (main app's) connection object’s activate method does not cause a message to be sent.
        
        /// This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
        func listener(_ listener: NSXPCListener,
                      shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool
        {
            newConnection.remoteObjectInterface = NSXPCInterface(with: XPCExecutableClientExportedInterface.self)
            
            // Configure the connection.
            // First, set the interface that the exported object implements.
            newConnection.exportedInterface = NSXPCInterface(with: XPCExecutableServiceExportedInterface.self)
            
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
            newConnection.activate()
            
            activeXPCConnection = newConnection
            
            // Returning true from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call invalidate() on the connection and return false.
            return true
        }
        
        private var activeXPCConnection: NSXPCConnection? = nil
    }
}
