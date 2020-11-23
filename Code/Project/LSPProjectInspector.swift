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
        serverConnection = try LSPServiceAPI.Language.Name(language).connectToLSPServer()
        
        serverConnection.serverDidSendNotification = { _ in }

        serverConnection.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Language server: \(errorOutput)")
        }
        
        serverConnection.serverDidSendError = { log($0) }
    }
    
    func symbols(for codeFile: CodeFolder.File) -> SymbolPromise
    {
        Promise
        {
            promise in
            
            initializationResult.whenCached
            {
                [weak self] initializationResult in

                do
                {
                    guard let self = self else { throw "\(Self.self) died" }
                    
                    _ = try initializationResult.get()
                    
                    let file = URL(fileURLWithPath: codeFile.path)
                    
                    let document: [String: JSONObject] =
                    [
                        "uri": file.absoluteString, // DocumentUri;
                        "languageId": self.language, // TODO: make enum for LSP language keys, and struct for this document
                        "version": 1,
                        "text": codeFile.content
                    ]
                    
                    try self.serverConnection.notify(.didOpen(doc: JSON(document)))
                    
                    try self.serverConnection.request(.docSymbols(inFile: file),
                                                      as: [LSPDocumentSymbol].self)
                    {
                        do { promise.fulfill(.success(try $0.get())) }
                        catch { promise.fulfill(.failure(error)) }
                    }
                }
                catch
                {
                    promise.fulfill(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Initializing the Language Server
    
    private lazy var initializationResult = initializeServer().cache()
    
    private func initializeServer() -> Promise<Result<Void, Error>>
    {
        Promise
        {
            promise in
            
            LSPServiceAPI.ProcessID.get().observed
            {
                [weak self] result in
                
                do
                {
                    guard let self = self else { throw "\(Self.self) died" }
                    
                    self.initializeServer(withClientProcessID: try result.get(),
                                          fulfill: promise)
                }
                catch
                {
                    promise.fulfill(.failure(error))
                }
            }
        }
    }
    
    private func initializeServer(withClientProcessID processID: Int,
                                  fulfill promise: Promise<Result<Void, Error>>)
    {
        do
        {
            try serverConnection.request(.initialize(folder: rootFolder,
                                                     clientProcessID: processID))
            {
                [weak self] _ in
                
                do
                {
                    guard let self = self else { throw "\(Self.self) died" }
                    try self.serverConnection.notify(.initialized)
                    promise.fulfill(.success(()))
                }
                catch
                {
                    promise.fulfill(.failure(error))
                }
            }
        }
        catch
        {
            promise.fulfill(.failure(error))
        }
    }
    
    // MARK: - Basic Configuration
    
    private let language: String
    private let rootFolder: URL
    private let serverConnection: LSP.ServerConnection
}
