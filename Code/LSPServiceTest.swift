import FoundationToolz
import Foundation
import SwiftyToolz

class LSPServiceTest
{
    private init() {}
    
    static func start()
    {
        do
        {
            webSocket = try LSPServiceAPI.Language.Name("swift").makeLSPWebSocket()
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
                case "initialize": break
//                    try? webSocket.send(.notification(.initialized))
//                    try? webSocket.send(.request(.openDoc()))
                case "workspace/symbol":
                    log("\(resultValue)")
                case "testDocument/documentSymbol":
                    log("\(resultValue)")
                case "textDocument/didOpen":
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
