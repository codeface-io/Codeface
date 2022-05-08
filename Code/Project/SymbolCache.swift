import SwiftLSP
import FoundationToolz
import Foundation
import SwiftObserver
import SwiftyToolz

class SymbolCache
{
    init(inspector: LSPProjectInspector)
    {
        self.inspector = inspector
    }
    
    func symbols(for codeFile: CodeFile) async throws -> [LSPDocumentSymbol]
    {
        if let symbols = symbolsByFilePath[codeFile.path]
        {
            return symbols
        }
        
        let symbols = try await inspector.symbols(for: codeFile)
        
        symbolsByFilePath[codeFile.path] = symbols
        
        return symbols
    }
    
    private let inspector: LSPProjectInspector
    private var symbolsByFilePath = [String: [LSPDocumentSymbol]]()
}
