import FoundationToolz
import Foundation
import SwiftyToolz

class LSPServiceWebSocket: SynchronousLSPServerConnection
{
    // MARK: - Initialize
    
    init(webSocket: WebSocket)
    {
        self.webSocket = webSocket
        
        webSocket.didReceiveData =
        {
            [weak self] data in self?.process(packet: data)
        }
        
        webSocket.didReceiveText =
        {
            [weak self] text in self?.serverDidSendErrorOutput(text)
        }
        
        webSocket.didReceiveError =
        {
            webSocket, error in webSocket.close(); log(error)
        }
    }
    
    // MARK: - Receive
    
    private func process(packet: Data)
    {
        do
        {
            let message = try LSP.Message(packet: packet)
            
            switch message
            {
            case .request(_): throw "Received request from LSP server"
            case .response(let response): serverDidSendResponse(response)
            case .notification(let notification): serverDidSendNotification(notification)
            }
        }
        catch
        {
            log(error)
        }
    }
    
    var serverDidSendResponse: (LSP.Message.Response) -> Void = { _ in }
    var serverDidSendNotification: (LSP.Message.Notification) -> Void = { _ in }
    var serverDidSendErrorOutput: (String) -> Void = { _ in }
    
    // MARK: - Send
    
    func send(_ message: LSP.Message) throws
    {
        log("Will send message: \(message)")
        
        try webSocket.send(message.packet())
        {
            $0.forSome { log($0) }
        }
    }
    
    // MARK: - WebSocket
    
    private let webSocket: WebSocket
}
