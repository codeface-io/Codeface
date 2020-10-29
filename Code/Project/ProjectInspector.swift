import SwiftLSP
import FoundationToolz
import SwiftObserver

protocol ProjectInspector
{
    func symbols(for codeFile: CodeFolder.File) -> Promise<Result<[LSPDocumentSymbol], Error>>
}
