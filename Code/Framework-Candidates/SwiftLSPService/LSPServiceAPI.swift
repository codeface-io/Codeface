import FoundationToolz
import Foundation

struct LSPServiceAPI
{
    struct Languages
    {
        static func get(handleResult: @escaping (Result<[String], URL.RequestError>) -> Void)
        {
            url.get([String].self, handleResult: handleResult)
        }
        
        private static let url = LSPServiceAPI.url + "languages"
    }
    
    struct Language
    {
        struct Name
        {
            init(_ languageName: String)
            {
                url = Language.url + languageName
            }
            
            func get(handleResult: @escaping (Result<String, URL.RequestError>) -> Void)
            {
                url.get(String.self, handleResult: handleResult)
            }
            
            func post(_ value : String,
                      handleError: @escaping (URL.RequestError?) -> Void)
            {
                url.post(value, handleError: handleError)
            }
            
            func connectToWebSocket() throws -> WebSocket
            {
                try (url + "websocket").webSocket()
            }
            
            private let url: URL
        }
        
        private static let url = LSPServiceAPI.url + "language"
    }
    
    private static let url = URL(string: "http://127.0.0.1:8080/lspservice/api")!
}
