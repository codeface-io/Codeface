extension CodeFolderArtifact
{
    func generateLinesOfCodeInCycles()
    {
        parts.forEach
        {
            switch $0.content.kind
            {
            case .file(let file):
                file.generateLinesOfCodeInCycles()
            case . subfolder(let subfolder):
                subfolder.generateLinesOfCodeInCycles()
            }
        }
        
        metrics.linesOfCodeOfPartsInCycles = parts.sum
        {
            $0.content.metrics.isInACycle ?? false ? $0.content.linesOfCode : $0.content.metrics.linesOfCodeOfPartsInCycles ?? 0
        }
    }
}

extension CodeFileArtifact
{
    fileprivate func generateLinesOfCodeInCycles()
    {
        symbols.forEach { $0.content.generateLinesOfCodeInCycles() }
        
        metrics.linesOfCodeOfPartsInCycles = symbols.sum
        {
            $0.content.metrics.isInACycle ?? false ? $0.content.linesOfCode : $0.content.metrics.linesOfCodeOfPartsInCycles ?? 0
        }
    }
}

extension CodeSymbolArtifact
{
    fileprivate func generateLinesOfCodeInCycles()
    {
        subsymbols.forEach { $0.content.generateLinesOfCodeInCycles() }
        
        metrics.linesOfCodeOfPartsInCycles = subsymbols.sum
        {
            $0.content.metrics.isInACycle ?? false ? $0.content.linesOfCode : $0.content.metrics.linesOfCodeOfPartsInCycles ?? 0
        }
    }
}
