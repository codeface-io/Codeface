import CodefaceCore
import SwiftLSP
import Foundation
import SwiftyToolz

extension XPCExecutable
{
    static func testForCodeface()
    {
        do
        {
            let lastLoaction = try CodebaseLocationPersister.loadCodebaseLocation()
            try XPCExecutable.testForCodeface(with: lastLoaction)
        }
        catch
        {
            log(error.readable)
        }
    }
    
    static func testForCodeface(with location: LSP.CodebaseLocation) throws
    {
        let client = try XPCExecutable.Client(serviceBundleID: "com.flowtoolz.codeface.CodefaceHelper")
        
        let serviceProxy = client.serviceProxy
        
        log("✅ Did create NSXPCConnection and retrieve service proxy")
        
        log("Gonna launch executable via service proxy ...")
        
        serviceProxy.launchExecutable(with: .init(path: "/usr/bin/xcrun", arguments: ["sourcekit-lsp"]))
        {
            error in
            
            if let error
            {
                log(error: "🛑 service failed to launch executable: " + error.readable.message)
                return
            }
            
            serviceProxy.getProcessID
            {
                processID in
                
                let initializeRequest = LSP.Message.request(.initialize(folder: location.folder,
                                                                        clientProcessID: processID))
                
                do
                {
                    let packetData = try LSP.Packet(initializeRequest).data
                    
                    serviceProxy.writeExecutableStdIn(packetData)
                    {
                        error in
                        
                        log(error?.readable.message ?? "Sent initialize request to xourcekit-lsp ✅")
                    }
                }
                catch
                {
                    log(error.readable)
                }
            }
        }
    }
}
