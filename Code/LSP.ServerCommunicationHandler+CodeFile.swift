import SwiftLSP
import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.ServerCommunicationHandler
{
    func symbols(for codeFile: CodeFile) async throws -> [LSPDocumentSymbol]
    {
        let file = URL(fileURLWithPath: codeFile.path)
        
        let document: [String: JSONObject] =
        [
            "uri": file.absoluteString, // DocumentUri;
            "languageId": language, // TODO: make enum for LSP language keys, and struct for this document
            "version": 1,
            "text": codeFile.content
        ]
        
        try notify(.didOpen(doc: JSON(document)))
            
        return try await request(.docSymbols(inFile: file))
    }
}
