extension CodeArtifact
{
    func generateMetrics()
    {
        switch kind
        {
        case .folder:
            var loc = 0
            for part in (parts ?? [])
            {
                part.generateMetrics()
                loc += part.metrics?.linesOfCode ?? 0
            }
            
            metrics = .init(linesOfCode: loc)
            
        case .file(let codeFile):
            for part in (parts ?? [])
            {
                part.generateMetrics()
            }
            
            metrics = .init(linesOfCode: codeFile.lines.count)
        
        case .symbol(let symbol):
            for part in (parts ?? [])
            {
                part.generateMetrics()
            }
            
            let lspSymbol = symbol.lspDocumentSymbol
            
            let loc = (lspSymbol.range.end.line - lspSymbol.range.start.line) + 1
            metrics = .init(linesOfCode: Int(loc))
        }
    }
}
