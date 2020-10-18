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
            [weak self] data in self?.process(lspFrame: data)
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
    
    private func process(lspFrame: Data)
    {
        do
        {
            let messageData = try LSP.extractContent(fromFrame: lspFrame)
            let message = try LSP.Message(JSONObject(messageData))
            
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
        let messageData = try message.jsonObject().data()
        
        log("Gonna send message:\n\(messageData.utf8String!)")
        
        webSocket.send(LSP.makeFrame(withContent: messageData))
        {
            $0.forSome { log($0) }
        }
    }
    
    // MARK: - WebSocket
    
    private let webSocket: WebSocket
}
