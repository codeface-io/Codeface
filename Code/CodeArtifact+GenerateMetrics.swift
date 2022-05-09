extension CodeArtifact
{
    func generateMetricsRecursively()
    {
        switch kind
        {
        case .folder:
            var loc = 0
            for child in (parts ?? [])
            {
                child.generateMetricsRecursively()
                loc += child.metrics?.linesOfCode ?? 0
            }
            metrics = .init(linesOfCode: loc)
            parts?.sort { $0.metrics?.linesOfCode ?? 0 > $1.metrics?.linesOfCode ?? 0 }
        
        case .file(let codeFile):
            metrics = .init(linesOfCode: codeFile.content.numberOfLines)
        
        case .symbol:
            break
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
