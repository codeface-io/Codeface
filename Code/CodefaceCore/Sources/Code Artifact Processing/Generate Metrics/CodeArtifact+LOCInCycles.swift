extension CodeFolderArtifact
{
    func generateLinesOfCodeInCycles()
    {
        let parts = partGraph.values
        
        parts.forEach
        {
            switch $0.kind
            {
            case .file(let file):
                file.generateLinesOfCodeInCycles()
            case . subfolder(let subfolder):
                subfolder.generateLinesOfCodeInCycles()
            }
        }
        
        metrics.linesOfCodeOfPartsInCycles = parts.sum
        {
            $0.metrics.isInACycle ?? false ? $0.linesOfCode : $0.metrics.linesOfCodeOfPartsInCycles ?? 0
        }
    }
}

extension CodeFileArtifact
{
    fileprivate func generateLinesOfCodeInCycles()
    {
        let symbols = symbolGraph.values
        
        symbols.forEach { $0.generateLinesOfCodeInCycles() }
        
        metrics.linesOfCodeOfPartsInCycles = symbols.sum
        {
            $0.metrics.isInACycle ?? false ? $0.linesOfCode : $0.metrics.linesOfCodeOfPartsInCycles ?? 0
        }
    }
}

extension CodeSymbolArtifact
{
    fileprivate func generateLinesOfCodeInCycles()
    {
        let subsymbols = subsymbolGraph.values
        
        subsymbols.forEach { $0.generateLinesOfCodeInCycles() }
        
        metrics.linesOfCodeOfPartsInCycles = subsymbols.sum
        {
            $0.metrics.isInACycle ?? false ? $0.linesOfCode : $0.metrics.linesOfCodeOfPartsInCycles ?? 0
        }
    }
}
