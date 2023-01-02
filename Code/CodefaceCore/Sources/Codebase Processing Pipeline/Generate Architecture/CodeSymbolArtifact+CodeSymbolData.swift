@BackgroundActor
public extension CodeSymbolArtifact
{
    convenience init(symbolData: CodeSymbol,
                     scope: any CodeArtifact,
                     enclosingFile: CodeFile)
    {
        // base case: create this symbol
        let codeLines = enclosingFile.lines[symbolData.range.start.line ... symbolData.range.end.line]
        
        self.init(name: symbolData.name,
                  kind: symbolData.kind,
                  range: symbolData.range,
                  selectionRange: symbolData.selectionRange,
                  code: codeLines.joined(separator: "\n"),
                  scope: scope)
        
        // create subsymbols recursively
        for childSymbolData in (symbolData.children ?? [])
        {
            subsymbolGraph.insert(.init(symbolData: childSymbolData,
                                        scope: self,
                                        enclosingFile: enclosingFile))
        }
        
        // remember symbol data, so we can add dependencies to the artifact hierarchy later
//        symbolDataHash[self] = symbolData
        
        Self.symbolHash[self] = symbolData
    }
    
    static var symbolHash = [CodeSymbolArtifact: CodeSymbol]()
}
