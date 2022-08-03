public extension CodeFolderArtifact
{
    func generateMetrics()
    {
        generateSizeMetrics()
        generateDependencyMetrics()
    }
    
    private func generateSizeMetrics()
    {
        subfolders.forEach { $0.generateSizeMetrics() }
        files.forEach { $0.generateSizeMetrics() }
            
        let locOfSubfolders = subfolders.reduce(0) { $0 + $1.linesOfCode }
        let locOfFiles = files.reduce(0) { $0 + $1.linesOfCode }
        let locOfAllParts = locOfSubfolders + locOfFiles
        
        subfolders.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllParts)
        }
        
        files.forEach
        {
            $0.metrics.sizeRelativeToAllPartsInScope = Double($0.linesOfCode) / Double(locOfAllParts)
        }
        
        metrics.linesOfCode = locOfAllParts
    }
    
    private func generateDependencyMetrics()
    {
        subfolders.forEach { $0.generateDependencyMetrics() }
        files.forEach { $0.generateDependencyMetrics() }
    }
}
