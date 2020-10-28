import FoundationToolz
import SwiftObserver

var projectInspector: ProjectInspector?

protocol ProjectInspector
{
    func symbols(for codeFile: CodeFolder.File) -> Promise<Result<[LSPDocumentSymbol], Error>>
}
