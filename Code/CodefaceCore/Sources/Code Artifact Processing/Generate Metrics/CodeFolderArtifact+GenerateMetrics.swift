public extension CodeFolderArtifact
{
    func generateMetrics()
    {
        // depth first! this is important
        for part in partGraph.values
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
        let parts = partGraph.values
        
        let locOfAllParts = parts.sum { $0.codeArtifact.linesOfCode }
        
        parts.forEach
        {
            $0.codeArtifact.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllParts)
        }
        
        metrics.linesOfCode = locOfAllParts
        metrics.linesOfCodeOfParts = locOfAllParts
    }
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toScopeGraph: &partGraph)
    }
}
