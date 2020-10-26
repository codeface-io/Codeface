import FoundationToolz
import Foundation
import SwiftyToolz
import Combine
/*
class LSPServiceTest
{
    private init() {}
    
    static func start()
    {
        LSPServiceAPI.ProcessID.get()
        {
            do
            {
                let processID = try $0.get()
                let swiftConnection = try LSPServiceAPI.Language.Name("swift").connectToLSPServer()
                connection = swiftConnection
                try test(with: swiftConnection, lspServiceProcessID: processID)
            }
            catch
            {
                log(error)
            }
        }
    }
    
    // MARK: - Server Connection
    
    private static var connection: LSP.ServerConnection?
    
    private static func test(with connection: LSP.ServerConnection,
                             lspServiceProcessID: Int) throws
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
        
        try connection.request(.initialize(folder: codeFolder,
                                           clientProcessID: lspServiceProcessID))
        {
            result in
            
            switch result
            {
            case .success(let serverCapabilities):
                log(serverCapabilities.description)
                
                let file = URL(fileURLWithPath: "/Users/seb/Desktop/TestProject/Sources/TestProject/TestProject.swift")
                
                let document: [String: JSONObject] =
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
                    try connection.request(.docSymbols(inFile: file),
                                           as: [LSPDocumentSymbol].self)
                    {
                        result in
                    
                        switch result
                        {
                        case .success(let symbols):
                            print(symbols.first?.name ?? "nil")
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
*/
class LSPProjectInspector: ProjectInspector
{
    init(language: String, projectFolder: URL) throws
    {
        
        self.language = language
        self.projectFolder = projectFolder
        serverConnection = try LSPServiceAPI.Language.Name(language).connectToLSPServer()
        
        serverConnection.serverDidSendNotification =
        {
            notification in

            log("got notification: " + notification.method + "\nparams: " + (notification.params?.description ?? "nil"))
        }

        serverConnection.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Error output from language server:\n\(errorOutput)")
        }
        
        serverConnection.serverDidSendError = { log($0) }
    }
    
    func symbols(for codeFile: CodeFolder.CodeFile,
                 handleResult: @escaping (Result<[CodeFolder.CodeFile.Symbol], Error>) -> Void)
    {
        ensureServerIsInitialized
        {
            [weak self] in
            
            guard let self = self else { return }
            
            let file = URL(fileURLWithPath: codeFile.path)
            
            do
            {
                log("About to read \(codeFile.path)")
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
                    result in
                
                    switch result
                    {
                    case .success(let lspSymbols):
                        let symbols = lspSymbols.map(\.codeFileSymbol)
                        handleResult(.success(symbols))
                    case .failure(let error):
                        handleResult(.failure(error))
                    }
                }
            }
            catch
            {
                handleResult(.failure(error))
            }
        }
    }
    
    // MARK: - Initializing the Language Server
    
    private func ensureServerIsInitialized(then execute: @escaping () -> Void)
    {
        if serverIsInitialized { return execute() }
        
        subscribers += severIsBeingInitialized.done
        {
            switch $0
            {
            case .success: execute()
            case .failure(let error): log(error)
            }
        }
    }
    
    private lazy var severIsBeingInitialized: Future<Void, Error> = initializeServer()
    
    private func initializeServer() -> Future<Void, Error>
    {
        Future
        {
            promise in
            
            LSPServiceAPI.ProcessID.get()
            {
                [weak self] in
                
                guard let self = self else
                {
                    promise(.failure("\(Self.self) was deallocated"))
                    return
                }
                
                do
                {
                    try self.initializeServer(withClientProcessID: try $0.get(),
                                              promise: promise)
                }
                catch
                {
                    promise(.failure(error))
                }
            }
        }
    }
    
    private func initializeServer(withClientProcessID processID: Int,
                                  promise: @escaping Future<Void, Error>.Promise) throws
    {
        try serverConnection.request(.initialize(folder: projectFolder,
                                                 clientProcessID: processID))
        {
            [weak self] result in
            
            guard let self = self else
            {
                promise(.failure("\(Self.self) was deallocated"))
                return
            }
            
            do
            {
                let serverCapabilities = try result.get()
                log(serverCapabilities.description)
                try self.serverConnection.notify(.initialized)
                self.serverIsInitialized = true
                promise(.success(()))
            }
            catch
            {
                promise(.failure(error))
            }
        }
    }
    
    private var serverIsInitialized = false
    
    // MARK: - Basic Configuration
    
    private let language: String
    private let projectFolder: URL
    private let serverConnection: LSP.ServerConnection
    private var subscribers = [AnyCancellable]()
}

extension LSPDocumentSymbol
{
    var codeFileSymbol: CodeFolder.CodeFile.Symbol
    {
        .init(name: name,
              kind: kind, // TODO: make enum for both: CodeFolder.CodeFile.Symbol and LSPDocumentSymbol
              subsymbols: children.map(\.codeFileSymbol))
    }
}

let fileContent = #"""
struct TestProject {
    var text = "Hello, World!"
}

"""#

extension Future
{
    func done(_ promise: @escaping Promise) -> AnyCancellable
    {
        sink
        {
            switch $0
            {
            case .failure(let error): promise(.failure(error))
            case .finished: break
            }
        }
        receiveValue:
        {
            promise(.success($0))
        }
    }
}
