import ProcessServiceClient
import CodefaceCore
import Combine
import SwiftLSP
import Foundation
import SwiftyToolz

func runProcessServiceTest()
{
    Task
    {
        do
        {
            // launch and observe an lsp-server via an XPC service
            
            let lspServerParams = Process.ExecutionParameters(path: "/usr/bin/xcrun",
                                                              arguments: ["sourcekit-lsp"])
            
            let hostedProcess = HostedProcess(named: "com.flowtoolz.codeface.CodefaceHelper",
                                              parameters: lspServerParams)
            
            try await hostedProcess.launch()
            
            observation = try await hostedProcess.processEventPublisher.sink
            {
                log("observation ended: \($0)")
            }
            receiveValue:
            {
                switch $0
                {
                case .stderr(let stdErr):
                    log(error: "lsp-server sent stdErr: " + (stdErr.utf8String ?? "decoding error"))
                case .stdout(let stdOut):
                    log("lsp-server sent stdOut: " + (stdOut.utf8String ?? "decoding error"))
                case .terminated(let terminationReason):
                    log("lsp-server did terminate with reason code \(terminationReason.rawValue)")
                }
            }
            
            // send initialize request to lsp-server with codebase location and parent/client process id
            
            let location = try CodebaseLocationPersister.loadCodebaseLocation()
            
            let connection = await hostedProcess.connection
            let xpcServiceProcessID = Int(connection.processIdentifier)
            
            let initializeRequest = LSP.Message.request(.initialize(folder: location.folder,
                                                                    clientProcessID: xpcServiceProcessID))
            let packetData = try LSP.Packet(initializeRequest).data
            
            try await hostedProcess.write(packetData)
            
            log("✅ Finished test procedure on client side")
        }
        catch
        {
            log(error.readable)
        }
    }
}

private var observation: AnyCancellable? = nil
