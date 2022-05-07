import LSPServiceKit
import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class LSPProjectInspector: ProjectInspector
{
    init(language: String, folder: URL) throws
    {
        self.language = language
        self.rootFolder = folder
        serverHandler = try LSPService.api.language(language).connectToLSPServer()
        
        serverHandler.serverDidSendNotification = { _ in }

        serverHandler.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Language server: \(errorOutput)")
        }
        
        serverHandler.serverDidSendErrorResult = { log($0) }
    }
    
    func symbols(for codeFile: CodeFolder.File) -> SymbolPromise
    {
        promise
        {
            initialization
        }
        .onSuccess
        {
            let file = URL(fileURLWithPath: codeFile.path)
            
            let document: [String: JSONObject] =
            [
                "uri": file.absoluteString, // DocumentUri;
                "languageId": self.language, // TODO: make enum for LSP language keys, and struct for this document
                "version": 1,
                "text": codeFile.content
            ]
            
            try self.serverHandler.notify(.didOpen(doc: JSON(document)))
            
            return Promise
            {
                promise in
            
                do
                {
                    try self.serverHandler.request(.docSymbols(inFile: file),
                                                      as: [LSPDocumentSymbol].self)
                    {
                        do { promise.fulfill(try $0.get()) }
                        catch { promise.fulfill(error) }
                    }
                }
                catch { promise.fulfill(error) }
            }
        }
    }
    
    // MARK: - Initializing the Language Server
    
    private lazy var initialization = initializeServer()
    
    private func initializeServer() -> ResultPromise<Void>
    {
        promise
        {
            LSPService.api.processID.get()
        }
        .onSuccess
        {
            self.initializeServer(withClientProcessID: $0)
        }
    }
    
    private func initializeServer(withClientProcessID id: Int) -> ResultPromise<Void>
    {
        Promise
        {
            promise in
            
            do
            {
                try serverHandler.request(.initialize(folder: rootFolder,
                                                         clientProcessID: id))
                {
                    [weak self] _ in
                    
                    do
                    {
                        guard let self = self else { throw "\(Self.self) died" }
                        try self.serverHandler.notify(.initialized)
                        promise.fulfill(())
                    }
                    catch { promise.fulfill(error) }
                }
            }
            catch { promise.fulfill(error) }
        }
    }
    
    // MARK: - Basic Configuration
    
    private let language: String
    private let rootFolder: URL
    private let serverHandler: LSP.ServerCommunicationHandler
}
