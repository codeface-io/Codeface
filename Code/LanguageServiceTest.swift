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
        do { test(with: try makeWebSocket(for: "swift")) }
        catch { log(error) }
    }
    
    private static func test(with websocket: WebSocket)
    {
        websocket.send(lspMessage: makeInitializationMessage())
    }
    
    // MARK: - Websocket
    
    private static func makeInitializationMessage() -> JSONRPCMessage {
        let initialize = InitializeRequest(rootURI: nil,
                                           capabilities: ClientCapabilities(workspace: nil,
                                                                            textDocument: nil),
                                           workspaceFolders: nil)
        return JSONRPCMessage.request(initialize, id: .number(1))
    }
    
    private static func makeWebSocket(for language: String) throws -> WebSocket
    {
        try LanguageServiceAPI.Language.Name(language).webSocket
        {
            data in log("received data from \(language.capitalized) websocket:\n\(data.utf8String!)")
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
