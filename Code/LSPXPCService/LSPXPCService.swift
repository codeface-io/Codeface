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
            let executable = try LSP.ServerExecutable(config: executableConfig)
            {
                lspPacket in
                
            }
            
            executable.run()
            
            activeExecutable = executable
            
            log("✅ Initialized LSP.ServerExecutable")
            reply("✅ Initialized LSP.ServerExecutable")
            
        }
        catch
        {
            log(error: "🛑 " + error.readable.message)
            reply(error.readable.message)
        }
    }
    
    private var activeExecutable: LSP.ServerExecutable? = nil
}
