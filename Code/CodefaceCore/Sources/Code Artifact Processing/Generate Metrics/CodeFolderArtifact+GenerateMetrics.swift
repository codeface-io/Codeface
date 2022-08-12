public extension CodeFolderArtifact
{
    func generateMetrics()
    {
        for part in parts
        {
            switch part.kind
            {
            case .subfolder(let subfolder): subfolder.generateMetrics()
            case .file(let file): file.generateMetrics()
            }
        }
        
        generateSizeMetrics()
        generateDependencyMetrics()
    }
    
    private func generateSizeMetrics()
    {
        let locOfAllParts = parts.reduce(0) { $0 + $1.codeArtifact.linesOfCode }
        
        parts.forEach
        {
            $0.codeArtifact.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllParts)
        }
        
        metrics.linesOfCode = locOfAllParts
    }
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toParts: parts,
                               dependencies: partDependencies)
    }
}
