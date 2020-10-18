import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.Message.Request
{
    static func initialize() -> Self
    {
//        let codeFolderPath = "/Users/seb/Desktop/GitHub Repos/CloudKid"
//        let codeFolder = URL(fileURLWithPath: codeFolderPath, isDirectory: true)
        
        let params: JSONObject =
        [
            "capabilities": JSONObject(),
            "rootUri": NSNull() // codeFolder.absoluteString
        ]
        
        return .init(id: .string(UUID().uuidString),
                     method: "initialize",
                     params: params)
    }
}
