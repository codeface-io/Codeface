import Foundation
import ProcessServiceServer

@main
enum ProcessServiceTestMain
{
    static func main()
    {
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
        do
        {
            try newConnection.configureProcessServiceServer()
        }
        catch
        {
            return false
        }

        newConnection.activate()

        return true
    }
}
