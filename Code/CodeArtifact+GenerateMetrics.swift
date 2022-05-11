extension CodeArtifact
{
    func generateMetricsRecursively()
    {
        switch kind
        {
        case .folder:
            var loc = 0
            for part in (parts ?? [])
            {
                part.generateMetricsRecursively()
                loc += part.metrics?.linesOfCode ?? 0
            }
            parts?.sort { $0.metrics?.linesOfCode ?? 0 > $1.metrics?.linesOfCode ?? 0 }
            
            metrics = .init(linesOfCode: loc)
            
        case .file(let codeFile):
            for part in (parts ?? [])
            {
                part.generateMetricsRecursively()
            }
            
            metrics = .init(linesOfCode: codeFile.content.numberOfLines)
        
        case .symbol(let symbol):
            for part in (parts ?? [])
            {
                part.generateMetricsRecursively()
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
