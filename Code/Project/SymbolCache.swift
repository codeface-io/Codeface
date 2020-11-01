import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver

class SymbolCache
{
    init(inspector: ProjectInspector)
    {
        self.inspector = inspector
    }
    
    func symbols(for codeFile: CodeFolder.File) -> SymbolPromise
    {
        Promise
        {
            promise in
            
            if let symbols = symbolsByFilePath[codeFile.path]
            {
                return promise.fulfill(.success(symbols))
            }
            
            inspector.symbols(for: codeFile).whenFulfilled
            {
                do    { promise.fulfill(.success(try $0.get())) }
                catch { promise.fulfill(.failure(error)) }
            }
        }
    }
    
    private let inspector: ProjectInspector
    private var symbolsByFilePath = [String: [LSPDocumentSymbol]]()
}
