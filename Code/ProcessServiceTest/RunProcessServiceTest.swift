import ProcessServiceClient
import CodefaceCore
import Combine
import SwiftLSP
import Foundation
import SwiftyToolz

enum ProcessServiceTest
{
    static func run()
    {
        Task
        {
            do
            {
                try await _run()
            }
            catch
            {
                log(error.readable)
            }
        }
    }
    
    private static func _run() async throws
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
        
        let serviceProcessID = await hostedProcess.serviceProcessID
        let initializeRequest = LSP.Message.request(.initialize(folder: location.folder,
                                                                clientProcessID: serviceProcessID))
        let packetData = try LSP.Packet(initializeRequest).data
        
        try await hostedProcess.write(packetData)
        
//        let launchOutput = try await hostedProcess.runAndReadStdout()
//        log("sourcekit-lsp output on launch: " + (launchOutput.utf8String ?? "nil"))
        
        log("✅ Did run test procedure on client side")
    }
    
    private static var observation: AnyCancellable? = nil
}
