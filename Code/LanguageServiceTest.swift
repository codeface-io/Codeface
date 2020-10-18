import FoundationToolz
import Foundation
import SwiftyToolz
import LanguageServerProtocol
import LanguageServerProtocolJSONRPC

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
            
            log("response result:\n\(response.result)")
        }
        
        webSocket.didReceiveNotification =
        {
            notification in
            
            log("notification method: " + notification.method)
            log("notification params: \(notification.params.debugDescription)")
        }
        
        let message = makeInitializationMessage()
        log("Gonna send message:\n" + message.encode()!.utf8String!)
        webSocket.send(lspMessage: message)
    }
    
    private static func makeInitializationMessage() -> JSONRPCMessage {
        let request = InitializeRequest(rootURI: nil,
                                        capabilities: ClientCapabilities(workspace: nil,
                                                                         textDocument: nil),
                                        workspaceFolders: nil)
        return JSONRPCMessage.request(request, id: .string(UUID().uuidString))
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
