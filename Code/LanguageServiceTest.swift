import FoundationToolz
import Foundation
import SwiftyToolz

class LanguageServiceTest
{
    private init() {}
    
    static func start()
    {
        do
        {
            webSocket = try LanguageServiceAPI.Language.Name("swift").makeWebSocket()
            webSocket.forSome { test(with: $0) }
        }
        catch { log(error) }
    }
    
    private static var webSocket: LSPWebSocket?
    
    // MARK: - Websocket
    
    private static func test(with webSocket: LSPWebSocket)
    {
        webSocket.didReceiveResponse =
        {
            response in
            
            log("response id:\n\(response.id)")
            log("response result:\n\(response.result)")
        }
        
        webSocket.didReceiveNotification =
        {
            notification in
            
            log("notification method: " + notification.method)
            log("notification params: \(notification.params.debugDescription)")
        }
        
        let messageData = makeInitializationMessage().data!
        log("Gonna send message:\n" + messageData.utf8String!)
        webSocket.send(messageData: messageData)
    }
    
    private static func makeInitializationMessage() -> String {
        """
        {
          "jsonrpc" : "2.0",
          "method" : "initialize",
          "id" : "9D76FD43-E7EE-4BE4-8D49-05C01A7F98B9",
          "params" : {
            "trace" : "off",
            "capabilities" : {

            }
          }
        }
        """
    }
    
    // MARK: - HTTP
    
    private static func requestAvailableLanguages()
    {
        LanguageServiceAPI.Languages.get() { result in
            switch result {
            case .success(let languages): log("Available languages: \(languages)")
            case .failure(let error): log(error)
            }
        }
    }
}
