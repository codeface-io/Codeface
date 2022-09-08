extension CodeFileArtifact
{
    convenience init(codeFile: CodeFile,
                     scope: CodeArtifact,
                     symbolDataHash: inout [CodeSymbolArtifact: CodeSymbolData])
    {
        self.init(name: codeFile.name,
                  uri: codeFile.uri,
                  codeLines: codeFile.code.components(separatedBy: .newlines),
                  scope: scope)
        
        for symbolData in codeFile.symbols
        {
            symbolGraph.insert(.init(symbolData: symbolData,
                                     scope: self,
                                     enclosingFile: codeFile,
                                     symbolDataHash: &symbolDataHash))
        }
    }
}
