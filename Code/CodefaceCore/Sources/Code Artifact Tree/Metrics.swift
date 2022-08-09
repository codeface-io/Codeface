public struct Metrics
{
    // MARK: - Size
    
    public var linesOfCode: Int?
    public var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    public var numberOfAllIncomingDependenciesInScope: Int?
    public var componentNumber: Int?
    public var dependencyDifferenceScope: Int?
}
