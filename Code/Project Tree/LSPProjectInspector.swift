import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz
import Combine

class LSPProjectInspector: ProjectInspector
{
    init(language: String, projectFolder: URL) throws
    {
        self.language = language
        self.projectFolder = projectFolder
        serverConnection = try LSPServiceAPI.Language.Name(language).connectToLSPServer()
        
        serverConnection.serverDidSendNotification = { _ in }

        serverConnection.serverDidSendErrorOutput =
        {
            errorOutput in log(error: "Language server: \(errorOutput)")
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
        initialization.done
        {
            switch $0
            {
            case .success: execute()
            case .failure(let error): log(error)
            }
        }
    }
    
    private lazy var initialization = initializeServer()
    
    private func initializeServer() -> Promise<Result<Void, Error>>
    {
        let promise = Promise<Result<Void, Error>>()
        
        LSPServiceAPI.ProcessID.get()
        {
            [weak self] in
            
            guard let self = self else
            {
                
                promise.send(.failure("\(Self.self) was deallocated"))
                return
            }
            
            do
            {
                self.initializeServer(withClientProcessID: try $0.get(),
                                      promise: promise)
            }
            catch
            {
                promise.send(.failure(error))
            }
        }
        
        return promise
    }
    
    private func initializeServer(withClientProcessID processID: Int,
                                  promise: Promise<Result<Void, Error>>)
    {
        do
        {
            try serverConnection.request(.initialize(folder: projectFolder,
                                                     clientProcessID: processID))
            {
                [weak self] _ in
                
                guard let self = self else
                {
                    promise.send(.failure("\(Self.self) was deallocated"))
                    return
                }
                
                do
                {
                    try self.serverConnection.notify(.initialized)
                    promise.send(.success(()))
                }
                catch
                {
                    promise.send(.failure(error))
                }
            }
        }
        catch
        {
            promise.send(.failure(error))
        }
    }
    
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
