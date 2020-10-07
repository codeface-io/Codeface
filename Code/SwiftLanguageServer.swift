import FoundationToolz
import Foundation
import SwiftyToolz

class SwiftLanguageServerController
{
    static let instance = SwiftLanguageServerController()
    private init() {}
    
    func start()
    {
        guard let url = URL(string: "http://127.0.0.1:8080") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "My LSP Request".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            error.forSome { print($0.localizedDescription) }
            print(String(data: data, encoding: .utf8) ?? "Error: couldn't decode data")
        }
        
        task.resume()
    }
}

/*
Content-Type: "application/vscode-jsonrpc; charset=utf-8"\r\n
\r\n
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
    }
}
*/
