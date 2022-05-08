import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class LSPProjectInspector
{
    init(server: LSP.ServerCommunicationHandler,
         language: String,
         folder: URL) throws
    {
        self.language = language
        self.rootFolder = folder
        self.server = server
    }
    
    func symbols(for codeFile: CodeFile) async throws -> [LSPDocumentSymbol]
    {
        let file = URL(fileURLWithPath: codeFile.path)
        
        let document: [String: JSONObject] =
        [
            "uri": file.absoluteString, // DocumentUri;
            "languageId": self.language, // TODO: make enum for LSP language keys, and struct for this document
            "version": 1,
            "text": codeFile.content
        ]
        
        try server.notify(.didOpen(doc: JSON(document)))
            
        let result = try await server.request(.docSymbols(inFile: file),
                                              as: [LSPDocumentSymbol].self)
        
        switch result
        {
        case .success(let symbols):
            return symbols
        case .failure(let errorResult):
            log(error: errorResult.description)
            throw errorResult
        }
    }
    
    // MARK: - Basic Configuration
    
    private let language: String
    private let rootFolder: URL
    private let server: LSP.ServerCommunicationHandler
}
