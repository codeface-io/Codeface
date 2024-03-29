import ProcessServiceClient
import Combine
import SwiftLSP
import Foundation
import SwiftyToolz

/**
 To work on this experiment
 1. Add ProcessService package to the project
 2. Add this file to app target "Codeface"
 3. Add "ProcessServiceTestMain.swift" to XPC service target "CodefaceHelper"
 4. Embedd XPC service target "CodefaceHelper" in app target "Codeface" via Targets -> Codeface -> Frameworks, Libraries, and Embedded Content
*/

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
        let initializeRequest = LSP.Message.request(.initialize(folder: location.folder))
        let packetData = try LSP.Packet(initializeRequest).data
        
        try await hostedProcess.write(packetData)
        
//        let launchOutput = try await hostedProcess.runAndReadStdout()
//        log("sourcekit-lsp output on launch: " + (launchOutput.utf8String ?? "nil"))
        
        log("✅ Did run test procedure on client side")
    }
    
    private static var observation: AnyCancellable? = nil
    private static let hostedProcess = HostedProcess(named: "com.flowtoolz.codeface.CodefaceHelper",
                                                     parameters: .init(path: "/usr/bin/xcrun",
                                                                       arguments: ["sourcekit-lsp"]))
}
