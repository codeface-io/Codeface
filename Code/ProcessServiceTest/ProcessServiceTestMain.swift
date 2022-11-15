import Foundation
import SwiftyToolz
import ProcessServiceServer

@main
enum ProcessServiceTestMain
{
    static func main()
    {
        log("✅ Launched XPC Service via ProcessService")
        let delegate = ServiceDelegate()
        let listener = NSXPCListener.service()

        listener.delegate = delegate
        listener.resume()
    }
}

final class ServiceDelegate: NSObject, NSXPCListenerDelegate
{
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection
                  newConnection: NSXPCConnection) -> Bool
    {
        log("✅ Created new connection via ProcessService")
        
        do
        {
            try newConnection.configureProcessServiceServer()
        }
        catch
        {
            log(error.readable)
            return false
        }

        newConnection.activate()

        return true
    }
}
