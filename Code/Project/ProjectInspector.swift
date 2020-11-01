import SwiftLSP
import FoundationToolz
import SwiftObserver

protocol ProjectInspector
{
    func symbols(for codeFile: CodeFolder.File) -> SymbolPromise
}

typealias SymbolPromise = Promise<Result<[LSPDocumentSymbol], Error>>
