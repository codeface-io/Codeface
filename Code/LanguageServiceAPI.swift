import FoundationToolz
import Foundation

struct LanguageServiceAPI
{
    struct Languages
    {
        static func get(handleResult: @escaping (Result<[String], Error>) -> Void)
        {
            languages.get([String].self, handleResult: handleResult)
        }
        
        private static let languages = languageServiceAPI + "languages"
    }
    
    static func websocket(forLanguage lang: String) -> URL
    {
        let apiString = languageServiceAPI.absoluteString
        let wsAPIString = apiString.replacingOccurrences(of: defaultScheme, with: "ws://")
        return URL(string: wsAPIString)! + lang
    }
    
    private static let languageServiceAPI = URL(string: defaultScheme + root)!
    private static let root = "127.0.0.1:8080/languageservice/api"
    private static let defaultScheme = "http://"
}
