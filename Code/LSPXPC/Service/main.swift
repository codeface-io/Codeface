import Foundation

let lspXPCService = LSPXPCService()         // acts as the listener delegate for this service
let xpcListener = NSXPCListener.service()
xpcListener.delegate = lspXPCService        // handles incoming connections
xpcListener.resume()                        // starts this service; does not return
