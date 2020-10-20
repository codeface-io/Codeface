import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.Message.Request
{
    static func openDoc() throws -> Self
    {
        let file = URL(fileURLWithPath: "/Users/seb/Desktop/GitHub Repos/SwiftLSPClient/SwiftLSPClient/LanguageServer.swift")
        
        let params: [String: Any] =
        [
            "textDocument": // TextDocumentItem
            [
                "uri": file.absoluteString, // DocumentUri;
                "languageId": "swift",
                "version": 1,
                "text": (try? String(contentsOf: file, encoding: .utf8))!
            ]
        ]
        
        return .init(method: "textDocument/didOpen", params: try JSON(params))
    }
    
    static func workspaceSymbol(query: String = "") throws -> Self
    {
        .init(method: "workspace/symbol", params: try JSON(["query": query]))
    }
    
    static func docSymbol() throws -> Self
    {
        let file = URL(fileURLWithPath: "/Users/seb/Desktop/GitHub Repos/SwiftLSPClient/SwiftLSPClient/LanguageServer.swift")
        
        let params = ["textDocument": ["uri": file.absoluteString]]
        
        return .init(method: "textDocument/documentSymbol", params: try JSON(params))
    }
    
    static func initialize() throws -> Self
    {
        let codeFolderPath = "/Users/seb/Desktop/GitHub Repos/sourcekit-lsp Fork"
        let codeFolder = URL(fileURLWithPath: codeFolderPath, isDirectory: true)
        
        let params: [String: Any] =
        [
            "capabilities": // ClientCapabilities
            [
                "textDocument": // TextDocumentClientCapabilities;
                [
                    "documentSymbol": //DocumentSymbolClientCapabilities;
                    [
                        "hierarchicalDocumentSymbolSupport": true
                    ]
                ],
            ],
            "rootUri": codeFolder.absoluteString //NSNull() //
        ]
        
        return .init(method: "initialize", params: try JSON(params))
    }
}

extension LSP.Message.Notification
{
    static var initialized: Self
    {
        .init(method: "initialized", params: .dictionary([:]))
    }
}
