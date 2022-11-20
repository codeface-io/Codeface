import Foundation
import SwiftyToolz
import ProcessServiceServer

@main
enum ProcessServiceTestMain
{
    static func main()
    {
        let delegate = ServiceDelegate()
        let listener = NSXPCListener.service()

        listener.delegate = delegate
        log("✅ About to resume listener on service side")
        listener.resume()
    }
}

final class ServiceDelegate: NSObject, NSXPCListenerDelegate
{
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection
                  newConnection: NSXPCConnection) -> Bool
    {
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
        
        log("✅ Activated connection on service side")

        return true
    }
}
