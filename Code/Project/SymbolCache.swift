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
            
            inspector.symbols(for: codeFile).observed
            {
                [weak self] in
                
                guard let self = self else { return }
                
                do
                {
                    let symbols = try $0.get()
                    self.symbolsByFilePath[codeFile.path] = symbols
                    promise.fulfill(.success(symbols))
                }
                catch
                {
                    promise.fulfill(.failure(error))
                }
            }
        }
    }
    
    private let inspector: ProjectInspector
    private var symbolsByFilePath = [String: [LSPDocumentSymbol]]()
}
