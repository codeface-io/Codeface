import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.Message.Request
{
    static func docSymbol() -> Self
    {
        let file = URL(fileURLWithPath: "/Users/seb/Desktop/GitHub Repos/SwiftLSPClient/SwiftLSPClient/LanguageServer.swift")
        let params: JSONObject = ["textDocument": ["uri": file.absoluteString]]
            
        return .init(method: "textDocument/documentSymbol", params: params)
    }
    
    static func initialize() -> Self
    {
        let codeFolderPath = "/Users/seb/Desktop/GitHub Repos/SwiftLSPClient"
        let codeFolder = URL(fileURLWithPath: codeFolderPath, isDirectory: true)
        
        let params: JSONObject =
        [
            "capabilities": // ClientCapabilities
            [
                "textDocument": // TextDocumentClientCapabilities;
                [
                    "documentSymbol": //DocumentSymbolClientCapabilities;
                    [
                        "dynamicRegistration": true,
                        "hierarchicalDocumentSymbolSupport": true
                    ]
                ],
            ],
            "rootUri": codeFolder.absoluteString //NSNull() //
        ]
        
        return .init(method: "initialize", params: params)
    }
}

extension LSP.Message.Notification
{
    static var initialized: Self
    {
        .init(method: "initialized", params: JSONObject())
    }
}
