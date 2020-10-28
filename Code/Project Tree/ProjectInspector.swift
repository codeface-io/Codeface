import FoundationToolz
import SwiftObserver

var projectInspector: ProjectInspector?

protocol ProjectInspector
{
    func symbols(for codeFile: CodeFolder.CodeFile) -> Promise<Result<[LSPDocumentSymbol], Error>>
}
