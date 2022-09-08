extension CodeFileArtifact
{
    convenience init(codeFile: CodeFile,
                     scope: CodeArtifact,
                     symbolDataHash: inout [CodeSymbolArtifact: CodeSymbolData])
    {
        self.init(codeFile: codeFile, scope: scope)
        
        for symbolData in codeFile.symbols
        {
            symbolGraph.insert(.init(symbolData: symbolData,
                                     scope: self,
                                     enclosingFile: codeFile,
                                     symbolDataHash: &symbolDataHash))
        }
    }
}
