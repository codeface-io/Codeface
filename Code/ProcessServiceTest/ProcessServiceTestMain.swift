import Foundation
import SwiftyToolz
import ProcessServiceServer
import ProcessServiceShared

@main
enum ProcessServiceTestMain
{
    static func main()
    {
        let delegate = ServiceDelegate()
        let listener = NSXPCListener.service()

        listener.delegate = delegate
        log("✅ Will resume listener on service side")
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
            _ = try newConnection.configureProcessServiceServer()
        }
        catch
        {
            log(error.readable)
            return false
        }

        newConnection.activate()
        
        log("✅ Did activate connection on service side")

        return true
    }
}
