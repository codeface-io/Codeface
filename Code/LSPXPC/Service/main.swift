import Foundation

// “By default, XPC services are run in the most restricted environment possible—sandboxed with minimal filesystem access, network access, and so on. Elevating a service’s privileges to root is not supported.”

// Create the delegate for the service.
let listenerDelegate = LSPXPCServiceListenerDelegate()

// Set up the one NSXPCListener for this service. It will handle all incoming connections.
let listener = NSXPCListener.service()
listener.delegate = listenerDelegate

// Resuming the serviceListener starts this service. This method does not return.
listener.resume()
