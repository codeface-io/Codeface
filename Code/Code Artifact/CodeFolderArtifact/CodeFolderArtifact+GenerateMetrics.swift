extension CodeFolderArtifact
{
    func generateMetrics()
    {
        subfolders.forEach { $0.generateMetrics() }
        files.forEach { $0.generateMetrics() }
            
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
}
