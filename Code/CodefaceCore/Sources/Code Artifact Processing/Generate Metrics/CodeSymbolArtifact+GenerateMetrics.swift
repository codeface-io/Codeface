import SwiftyToolz

extension CodeSymbolArtifact
{
    func generateMetrics()
    {
        subsymbols.forEach { $0.content.generateMetrics() }
        
        generateSizeMetrics()
        generateDependencyMetrics()
    }
    
    private func generateSizeMetrics()
    {
        subsymbols.forEach { $0.content.generateSizeMetrics() }
        
        let locOfAllSubsymbols = subsymbols.sum { $0.content.linesOfCode }
        metrics.linesOfCodeOfParts = locOfAllSubsymbols
        
        subsymbols.forEach
        {
            $0.content.metrics.sizeRelativeToAllPartsInScope = Double($0.content.linesOfCode) / Double(locOfAllSubsymbols)
        }
        
        let loc = (range.end.line - range.start.line) + 1
        
        metrics.linesOfCode = loc
    }
    
    private func generateDependencyMetrics()
    {
        writeDependencyMetrics(toParts: subsymbols,
                               dependencies: &subsymbolDependencies)
    }
}

extension CodeSymbolArtifact: Hashable
{
    public static func == (lhs: CodeSymbolArtifact,
                           rhs: CodeSymbolArtifact) -> Bool
    {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
}
