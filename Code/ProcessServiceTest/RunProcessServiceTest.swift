import ProcessServiceClient
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

            try await remoteProcess.launch()
        }
        catch
        {
            log(error.readable)
        }
    }
}
