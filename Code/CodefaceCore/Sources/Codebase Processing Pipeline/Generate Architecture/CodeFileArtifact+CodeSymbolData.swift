public extension CodeFileArtifact
{
    convenience init(codeFile: CodeFile,
                     scope: any CodeArtifact,
                     symbolDataHash: inout [CodeSymbolArtifact: CodeSymbol])
    {
        self.init(name: codeFile.name,
                  codeLines: codeFile.code.components(separatedBy: .newlines),
                  scope: scope)
        
        for symbolData in (codeFile.symbols ?? [])
        {
            symbolGraph.insert(.init(symbolData: symbolData,
                                     scope: self,
                                     enclosingFile: codeFile,
                                     symbolDataHash: &symbolDataHash))
        }
    }
}
