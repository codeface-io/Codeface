import FoundationToolz
import Foundation
import SwiftyToolz

class SwiftLanguageServerController
{
    static let instance = SwiftLanguageServerController()
    private init() {}
    
    func start()
    {
        setupWebSocket()
        sendTestMessageToWebsocket()
//        sendTestMessageToWebsocket()
//        requestAvailableLanguages()
    }
    
    // MARK: - WebSocket
    
    func sendTestMessageToWebsocket()
    {
        websocket?.send(createTestMessageData()) { $0.forSome { log($0) } }
    }
    
    fileprivate func createTestMessageData() -> Data {
        let messageContent = """
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params":
            {
                "capabilities": {},
                "trace": "off"
            }
        }
        """
//        let messageContent = "{ }"
        
        let messageContentData = messageContent.data(using: .utf8)!
        let messageHeader = "Content-Length: \(messageContentData.count)\r\n\r\n"
        let messageHeaderData = messageHeader.data(using: .utf8)!
        return messageHeaderData + messageContentData
    }
    
    func setupWebSocket()
    {
        let swiftEndpoint = LanguageServiceAPI.Language.Name("swift")
        
        websocket = swiftEndpoint.webSocket
        {
            data in log("received data from websocket:\n\(data.utf8String!)")
        }
        receiveText:
        {
            text in log("received text from websocket:\n\(text)")
        }
        receiveError:
        {
            [weak self] error in log(error); self?.websocket?.close()
        }
    }
    
    private var websocket: WebSocket?
    
    // MARK: - HTTP
    
    func requestAvailableLanguages()
    {
        LanguageServiceAPI.Languages.get() { result in
            switch result {
            case .success(let languages): log("Available languages: \(languages)")
            case .failure(let error): log(error)
            }
        }
    }
}
