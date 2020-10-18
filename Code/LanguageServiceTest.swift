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
            let newWebSocket = try makeWebSocket(for: "swift")
            websocket = newWebSocket
            test(with: newWebSocket)
        }
        catch { log(error) }
    }
    
    private static var websocket: WebSocket?
    
    private static func test(with websocket: WebSocket)
    {
        let message = makeInitializationMessage()
        log("Message encoded:\n" + message.encode()!.utf8String!)
        websocket.send(lspMessage: message)
    }
    
    // MARK: - Websocket
    
    private static func makeInitializationMessage() -> JSONRPCMessage {
        let request = InitializeRequest(rootURI: nil,
                                        capabilities: ClientCapabilities(workspace: nil,
                                                                         textDocument: nil),
                                        workspaceFolders: nil)
        return JSONRPCMessage.request(request, id: .number(1234))
    }
    
    private static func makeWebSocket(for language: String) throws -> WebSocket
    {
        try LanguageServiceAPI.Language.Name(language).webSocket
        {
            process(responseLSPFrame: $0)
        }
        receiveText:
        {
            text in log("received text from \(language.capitalized) websocket:\n\(text)")
        }
        receiveError:
        {
            websocket, error in websocket.close(); log(error)
        }
    }
    
    private static func process(responseLSPFrame lspFrame: Data)
    {
        guard let content = LSP.extractContent(fromFrame: lspFrame) else { return }
        
        do
        {
            let anything = try JSONSerialization.jsonObject(with: content, options: [])
            
            guard let responseJSON = anything as? JSONObject else { return }
            
            let response = try LSPResponse(json: responseJSON)
            
            switch response.result
            {
            case .success(let anyValue):
                if let resultJSON = anyValue as? JSONObject
                {
                    log("received capabilities from websocket:\n\(resultJSON["capabilities"] ?? "nil")")
                }
            case .failure(_):
                break
            }
        }
        catch
        {
            log(error)
        }
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

extension JSONObject
{
    func obj(_ key: String) -> JSONObject?
    {
        self[key] as? JSONObject
    }
    
    func arr(_ key: String) -> JSONArray?
    {
        self[key] as? JSONArray
    }
    
    func str(_ key: String) -> String?
    {
        self[key] as? String
    }
    
    func int(_ key: String) throws -> Int
    {
        guard let result = self[key] as? Int else { throw #file + #function }
        return result
    }
    
    func boo(_ key: String) -> Bool?
    {
        self[key] as? Bool
    }
    
    func any(_ key: String) throws -> Any
    {
        guard let result = self[key] else { throw #file + #function }
        return result
    }
}

extension JSONArray
{
    var obj: [JSONObject]?
    {
        self as? [JSONObject]
    }
    
    var arr: [JSONArray]?
    {
        self as? [JSONArray]
    }
    
    func str() throws -> [String]
    {
        guard let result = self as? [String] else { throw #file + #function }
        return result
    }
    
    var int: [Int]?
    {
        self as? [Int]
    }
    
    var boo: [Bool]?
    {
        self as? [Bool]
    }
}

typealias JSONObject = [String : Any]
typealias JSONArray = [Any]
