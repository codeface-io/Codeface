import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class SymbolCache
{
    init(inspector: ProjectInspector)
    {
        self.inspector = inspector
    }
    
    func symbols(for codeFile: CodeFolder.File) -> SymbolPromise
    {
        if let symbols = symbolsByFilePath[codeFile.path]
        {
            return .fulfilled(symbols)
        }
        
        return promise
        {
            inspector.symbols(for: codeFile)
        }
        .whenSucceeded
        {
            self.symbolsByFilePath[codeFile.path] = $0
        }
        failed:
        {
            log($0)
        }
    }
    
    private let inspector: ProjectInspector
    private var symbolsByFilePath = [String: [LSPDocumentSymbol]]()
}
