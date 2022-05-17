import SwiftLSP
import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.ServerCommunicationHandler
{
    func symbols(for codeFile: CodeFile) async throws -> [LSPDocumentSymbol]
    {
        let uri: LSPDocumentUri = URL(fileURLWithPath: codeFile.path).absoluteString
        
        let document: [String: JSONObject] =
        [
            "uri": uri, // DocumentUri;
            "languageId": language, // TODO: make enum for LSP language keys, and struct for this document
            "version": 1,
            "text": codeFile.lines.joined(separator: "\n")
        ]
        
        try notify(.didOpen(doc: JSON(document)))
            
        return try await requestDocumentSymbols(inFile: uri)
    }
}
