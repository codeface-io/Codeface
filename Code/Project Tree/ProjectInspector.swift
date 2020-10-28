import SwiftObserver

var projectInspector: ProjectInspector?

protocol ProjectInspector
{
    func symbols(for codeFile: CodeFolder.CodeFile) -> Promise<Result<[CodeFolder.CodeFile.Symbol], Error>>
}
