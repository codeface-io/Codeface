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
            
            metrics = .init(linesOfCode: codeFile.content.numberOfLines)
        
        case .symbol(let symbol):
            for part in (parts ?? [])
            {
                part.generateMetrics()
            }
            
            let loc = (symbol.range.end.line - symbol.range.start.line) + 1
            metrics = .init(linesOfCode: Int(loc))
        }
    }
}

extension String
{
    var numberOfLines: Int
    {
        var result = 0
        enumerateLines { _, _ in result += 1 }
        return result
    }
}
