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
    }
    
    // MARK: - WebSocket
    
    func sendTestMessageToWebsocket()
    {
        guard let websocket = websocket else {
            log(error: "websocket has not been created")
            return
        }
        
        let testData = createTestMessageData()
        print("gonna send test data of \(testData.count) bytes ...")
        
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
        guard let url = URL(string: "ws://127.0.0.1:8080") else
        {
            log(error: "could not create url for websocket")
            return
        }
        
        let task = URLSession.shared.webSocketTask(with: url)
        
        task.receive
        {
            result in
            
            switch result
            {
            case .success(let response):
                switch response
                {
                case .data(let dataMessage):
                    log(String(data: dataMessage,
                               encoding: .utf8) ?? "error decoding data message")
                case .string(let stringMessage):
                    log(stringMessage)
                @unknown default:
                    log(error: "unknown response type")
                }
            case .failure(let error):
                log(error: error.localizedDescription)
            }
        }
        
        task.resume()
        
        websocket = task
    }
    
    private var websocket: URLSessionWebSocketTask?
    
    // MARK: - REST
    
    func testHTTPEndpoint()
    {
        guard let url = URL(string: "http://127.0.0.1:8080") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "My LSP Request".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            error.forSome { print($0.localizedDescription) }
            log(String(data: data, encoding: .utf8) ?? "Error: couldn't decode data")
        }
        
        task.resume()
    }
}
