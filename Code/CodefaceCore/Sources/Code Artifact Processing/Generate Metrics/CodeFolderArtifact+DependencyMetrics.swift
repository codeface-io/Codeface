public extension CodeFolderArtifact
{
    func generateDependencyMetrics()
    {
        // depth first! this is important
        for part in partGraph.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder): subfolder.generateDependencyMetrics()
            case .file(let file): file.generateDependencyMetrics()
            }
        }
    
        writeDependencyMetrics(toScopeGraph: &partGraph)
    }
}

extension CodeFileArtifact
{
    func generateDependencyMetrics()
    {
        symbolGraph.values.forEach { $0.generateDependencyMetrics() }
        
        writeDependencyMetrics(toScopeGraph: &symbolGraph)
    }
}

extension CodeSymbolArtifact
{
    func generateDependencyMetrics()
    {
        subsymbolGraph.values.forEach { $0.generateDependencyMetrics() }
        
        writeDependencyMetrics(toScopeGraph: &subsymbolGraph)
    }
}
