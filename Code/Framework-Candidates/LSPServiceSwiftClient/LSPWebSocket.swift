import FoundationToolz
import Foundation
import SwiftyToolz

class LSPWebSocket
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
            [weak self] text in self?.didReceiveErrorOutput(text)
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
            case .response(let response): didReceiveResponse(response)
            case .notification(let notification): didReceiveNotification(notification)
            }
        }
        catch
        {
            log(error)
        }
    }
    
    var didReceiveResponse: (LSP.Message.Response) -> Void = { _ in }
    var didReceiveNotification: (LSP.Message.Notification) -> Void = { _ in }
    var didReceiveErrorOutput: (String) -> Void = { _ in }
    
    // MARK: - Send
    
    func send(_ message: LSP.Message) throws
    {
        try webSocket.send(message.packet())
        {
            $0.forSome { log($0) }
        }
    }
    
    // MARK: - WebSocket
    
    private let webSocket: WebSocket
}
