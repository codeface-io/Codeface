import FoundationToolz
import Foundation
import SwiftLSP
import SwiftyToolz

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class LSPXPCService: NSObject, LSPXPCServiceProtocol
{
    override init()
    {
        super.init()
        
        log("Initializing \(Self.self)")
    }
    
    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
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
    
    
    func writeToActiveExecutable(_ data: Data)
    {
        guard let activeExecutable else
        {
            log(warning: "Tried to write data to active executable while the latter is nil")
            return
        }
        
        activeExecutable.receive(input: data)
    }
    
    private var activeExecutable: LSP.ServerExecutable? = nil
}
