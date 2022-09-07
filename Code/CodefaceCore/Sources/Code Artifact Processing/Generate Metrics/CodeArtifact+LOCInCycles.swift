extension CodeFolderArtifact
{
    func generateLinesOfCodeInCycles()
    {
        traverseDepthFirst { $0.calculateLOCsOfPartsInCycles() }
    }
}

extension CodeArtifact
{
    func calculateLOCsOfPartsInCycles()
    {
        metrics.linesOfCodeOfPartsInCycles = parts.sum { $0.metrics.linesOfCodeInCycles }
    }
}
