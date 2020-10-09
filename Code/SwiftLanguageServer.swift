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
        sendTestMessageToWebsocket()
//        testHTTPEndpoint()
    }
    
    // MARK: - WebSocket
    
    func sendTestMessageToWebsocket()
    {
        guard let websocket = websocket else {
            log(error: "websocket has not been created")
            return
        }
        
        let testData = createTestMessageData()
        
        websocket.send(.data(testData))
        {
            error in error.forSome { log(error: $0.localizedDescription) }
        }
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
        
        let messageContentData = messageContent.data(using: .utf8)!
        let messageHeader = "Content-Length: \(messageContentData.count)\r\n\r\n"
        let messageHeaderData = messageHeader.data(using: .utf8)!
        return messageHeaderData + messageContentData
    }
    
    func setupWebSocket()
    {
        let url = languageServiceURLWebSocket + "api/swift"
        websocket = URLSession.shared.webSocketTask(with: url)
        observeWebSocket()
        websocket?.resume()
    }
    
    func observeWebSocket() {
        waitForAnotherMessageFromWebSocketRecursively()
    }
    
    func waitForAnotherMessageFromWebSocketRecursively() {
        websocket?.receive
        {
            [weak self] result in
            
            switch result
            {
            case .success(let response):
                switch response
                {
                case .data(let messageData):
                    let messageString = String(data: messageData,
                                               encoding: .utf8) ?? "error decoding message"
                    log("received data from websocket:\n\(messageString)")
                case .string(let messageString):
                    log("received string from websocket:\n\(messageString)")
                @unknown default:
                    log(error: "unknown response type")
                }
                self?.waitForAnotherMessageFromWebSocketRecursively()
            case .failure(let error):
                log(error: error.localizedDescription)
            }
        }
    }
    
    private var websocket: URLSessionWebSocketTask?
    
    // MARK: - HTTP
    
    func testHTTPEndpoint()
    {
        let url = languageServiceURLHTTP + "dashboard/swift"
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            error.forSome { print($0.localizedDescription) }
            log(String(data: data, encoding: .utf8) ?? "Error: couldn't decode data")
        }
        
        task.resume()
    }
    
    let languageServiceURLHTTP = URL(string: "http://127.0.0.1:8080/languageservice")!
    let languageServiceURLWebSocket = URL(string: "ws://127.0.0.1:8080/languageservice")!
}
