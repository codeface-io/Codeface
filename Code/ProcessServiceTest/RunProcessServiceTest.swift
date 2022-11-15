import ProcessServiceClient
import Foundation
import SwiftyToolz

func RunProcessServiceTest()
{
    Task
    {
        let params = Process.ExecutionParameters(path: "/usr/bin/xcrun",
                                                 arguments: ["sourcekit-lsp"])
        
        do
        {
            let remoteProcess = HostedProcess(named: "com.flowtoolz.codeface.CodefaceHelper",
                                              parameters: params)
            
            let stdOut = try await remoteProcess.runAndReadStdout()
            
            let stdOutString = String(data: stdOut, encoding: .utf8) ?? "nothing"
            
            log("✅ stdOut: \(stdOutString)")
        }
        catch
        {
            log(error.readable)
        }
    }
}
