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
        if let symbols = symbolsByFilePath[codeFile.path]
        {
            return .fulfilled(symbols)
        }
        
        return promise
        {
            inspector.symbols(for: codeFile)
        }
        .mapSuccess
        {
            self.symbolsByFilePath[codeFile.path] = $0
            return $0
        }
    }
    
    private let inspector: ProjectInspector
    private var symbolsByFilePath = [String: [LSPDocumentSymbol]]()
}
