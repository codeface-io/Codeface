import Foundation

let service = XPCExecutable.Service()   // acts as the listener delegate for this service
let listener = NSXPCListener.service()
listener.delegate = service             // handles incoming connections
listener.resume()                       // starts this service; does not return
