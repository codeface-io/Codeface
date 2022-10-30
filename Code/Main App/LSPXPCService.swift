import Foundation

func experiment()
{
    /**
     "the main application and the helper have an instance of NSXPCConnection. The main application creates its connection object itself, which causes the helper to launch."
     
     https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html#//apple_ref/doc/uid/10000172i-SW6-SW19
     */
    let connection = NSXPCConnection(serviceName: "com.flowtoolz.LSPXPCService")
    
//    connection.exportedInterface
}
