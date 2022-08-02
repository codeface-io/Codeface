public struct Metrics
{
    // MARK: - Size
    
    public var linesOfCode: Int?
    public var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    public var numberOfAllIncomingDependenciesInScope: Int = 0
    public var componentNumber: Int?
}
