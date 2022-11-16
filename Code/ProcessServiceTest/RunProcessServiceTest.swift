import ProcessServiceClient
import ProcessServiceShared
import Foundation
import SwiftyToolz

func RunProcessServiceTest()
{
    Task
    {
        let parameters = Process.ExecutionParameters(path: "/usr/bin/xcrun",
                                                     arguments: ["sourcekit-lsp"])
        
        do
        {
            let remoteProcess = HostedProcess(named: "com.flowtoolz.codeface.CodefaceHelper",
                                              parameters: parameters)
            
            let connection = await remoteProcess.connection
            
            try await connection.withContinuation
            {
                (service: ProcessServiceXPCProtocol, continuation) in
                
                log("✅ retrieved service proxy")
                
                service.launchProcess(at: URL(fileURLWithPath: parameters.path),
                                      arguments: parameters.arguments,
                                      environment: parameters.environment,
                                      currentDirectoryURL: parameters.currentDirectoryURL,
                                      reply: continuation.resumingHandler)
            }
            
            // try await remoteProcess.launch()
        }
        catch
        {
            log(error.readable)
        }
    }
}
