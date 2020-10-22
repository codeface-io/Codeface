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
            connection = try LSPServiceAPI.Language.Name("swift").connectToLSPServer()
            try connection.forSome { try test(with: $0) }
        }
        catch { log(error) }
    }
    
    private static var connection: LSPServerAsyncConnection?
    
    // MARK: - Websocket
    
    private static func test(with connection: LSPServerAsyncConnection) throws
    {
        connection.serverDidSendNotification =
        {
            notification in

            log("got notification: " + notification.method + "\nparams: " + (notification.params?.description ?? "nil"))
        }

        connection.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Error output from language server:\n\(errorOutput)")
        }
        
        connection.serverDidSendError = { log($0) }
        
        let codeFolderPath = "/Users/seb/Desktop/TestProject"
        let codeFolder = URL(fileURLWithPath: codeFolderPath, isDirectory: true)
        
        let capabilities: [String: Any] =
        [
            "textDocument": // TextDocumentClientCapabilities;
            [
                "documentSymbol": //DocumentSymbolClientCapabilities;
                [
                    "hierarchicalDocumentSymbolSupport": true
                ]
            ]
        ]
        
        try connection.request(.initialize(folder: codeFolder,
                                        capabilities: JSON(capabilities)))
        {
            result in
            
            switch result
            {
            case .success(let serverCapabilities):
                log(serverCapabilities.description)
                
                let file = URL(fileURLWithPath: "/Users/seb/Desktop/TestProject/Sources/TestProject/TestProject.swift")
                
                let document: JSONObjectDictionary =
                [
                    "uri": file.absoluteString, // DocumentUri;
                    "languageId": "swift",
                    "version": 1,
                    "text": fileContent
                ]
                
                do
                {
                    try connection.notify(.initialized)
                    try connection.notify(.didOpen(doc: JSON(document)))
                    try connection.request(.docSymbol(file: file))
                    {
                        result in
                        
                        switch result
                        {
                        case .success(let symbols):
                            log("doc symbols: \(symbols)")
                        case .failure(let error):
                            log(error)
                        }
                    }
                }
                catch
                {
                    log(error)
                }
            case .failure(let error):
                log(error)
            }
        }
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

let fileContent = #"""
struct TestProject {
    var text = "Hello, World!"
}

"""#
