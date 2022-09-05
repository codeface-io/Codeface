public extension CodeFolderArtifact
{
    func generateMetrics()
    {
        // depth first! this is important
        for part in parts
        {
            switch part.content.kind
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
        let locOfAllParts = parts.sum { $0.content.codeArtifact.linesOfCode }
        
        parts.forEach
        {
            $0.content.codeArtifact.metrics.sizeRelativeToAllPartsInScope = Double($0.content.linesOfCode) / Double(locOfAllParts)
        }
        
        metrics.linesOfCode = locOfAllParts
        metrics.linesOfCodeOfParts = locOfAllParts
    }
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toParts: parts,
                               dependencies: &partDependencies)
    }
}
