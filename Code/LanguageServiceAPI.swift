import FoundationToolz
import Foundation

struct LanguageServiceAPI
{
    struct Languages
    {
        static func get(handleResult: @escaping (Result<[String], URL.RequestError>) -> Void)
        {
            languages.get([String].self, handleResult: handleResult)
        }
        
        private static let languages = languageServiceAPI + "languages"
    }
    
    struct Language
    {
        struct Name
        {
            init(_ languageName: String)
            {
                self.languageName = language + languageName
            }
            
            func get(handleResult: @escaping (Result<String, URL.RequestError>) -> Void)
            {
                languageName.get(String.self, handleResult: handleResult)
            }
            
            func post(_ value : String,
                      handleError: @escaping (URL.RequestError?) -> Void)
            {
                languageName.post(value, handleError: handleError)
            }
            
            func webSocket(receiveData: @escaping (Data) -> Void,
                           receiveText: @escaping (String) -> Void,
                           receiveError: @escaping (Error) -> Void) -> WebSocket?
            {
                (languageName + "websocket").webSocket(receiveData: receiveData,
                                                        receiveText: receiveText,
                                                        receiveError: receiveError)
            }
            
            private let languageName: URL
        }
        
        private static let language = languageServiceAPI + "language"
    }
    
    private static let languageServiceAPI = URL(string: "http://127.0.0.1:8080/languageservice/api")!
}
