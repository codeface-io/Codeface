public struct Metrics
{
    // MARK: - Size
    
    public var linesOfCode: Int?
    public var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    public var componentRank: Int?
    public var topologicalRankInComponent: Int?
    public var ingoingDependenciesInScope: Int?
    public var outgoingDependenciesInScope: Int?
}
