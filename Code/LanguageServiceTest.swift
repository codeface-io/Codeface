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
            let swiftEndpoint = LanguageServiceAPI.Language.Name("swift")
            webSocket = try LSPWebSocket(webSocket: swiftEndpoint.makeWebSocket())
            try webSocket.forSome { try test(with: $0) }
        }
        catch { log(error) }
    }
    
    private static var webSocket: LSPWebSocket?
    
    // MARK: - Websocket
    
    private static func test(with webSocket: LSPWebSocket) throws
    {
        webSocket.didReceiveResponse =
        {
            response in
            
            switch response.result
            {
            case .success(let resultValue):
                log("response id: \(response.id)\nresponse result:\n\(resultValue)")
            case .failure(let error):
                log(error)
            }
        }
        
        webSocket.didReceiveNotification =
        {
            notification in
            
            log("notification method: " + notification.method)
            log("notification params: \(notification.params.debugDescription)")
        }
        
        webSocket.didReceiveErrorOutput =
        {
            errorOutput in log(error: "Error output from language server:\n\(errorOutput)")
        }
        
        let message = LSP.Message.request(.init(id: .string(UUID().uuidString),
                                                method: "initialize",
                                                params: ["capabilities" : JSONObject()]))
        
        try webSocket.send(message)
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
