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
            let swiftEndpoint = LSPServiceAPI.Language.Name("swift")
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
            
            log("got response for: " + response.id.description)
            
            switch response.result
            {
            case .success(let resultValue):
                switch response.id.description
                {
                case "test: initialize":
                    try? webSocket.send(.notification(.initialized))
                    try? webSocket.send(.request(.workspaceSymbol()))
                case "test: workspace symbol":
                    log("\(resultValue)")
                case "test: doc symbol":
                    log("\(resultValue)")
                default:
                    log(error: "wtf")
                }
            case .failure(let error):
                log(error)
            }
        }
        
        webSocket.didReceiveNotification =
        {
            notification in
            
            log("notification: method: " + notification.method + ", params:\n" + notification.params.debugDescription)
        }
        
        webSocket.didReceiveErrorOutput =
        {
            errorOutput in log(error: "Error output from language server:\n\(errorOutput)")
        }
        
        try webSocket.send(.request(.initialize()))
    }
    
    // MARK: - HTTP
    
    private static func requestAvailableLanguages()
    {
        LSPServiceAPI.Languages.get()
        {
            result in
            
            switch result
            {
            case .success(let languages): log("Available languages: \(languages)")
            case .failure(let error): log(error)
            }
        }
    }
}
