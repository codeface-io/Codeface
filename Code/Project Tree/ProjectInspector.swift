var projectInspector: ProjectInspector?

protocol ProjectInspector
{
    func symbols(for codeFile: CodeFolder.CodeFile,
                 handleResult: @escaping (Result<[CodeFolder.CodeFile.Symbol], Error>) -> Void)
}
