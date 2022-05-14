extension CodeArtifact
{
    func sort()
    {
        for part in (parts ?? [])
        {
            part.sort()
        }
        
        switch kind
        {
        case .folder:
            parts?.sort { $0.metrics?.linesOfCode ?? 0 > $1.metrics?.linesOfCode ?? 0 }
            
        case .file, .symbol:
            parts?.sort { $0.symbol?.range.start.line ?? 0 < $1.symbol?.range.start.line ?? 0 }
        }
    }
}
