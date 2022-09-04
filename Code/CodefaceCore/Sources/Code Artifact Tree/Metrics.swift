public struct Metrics
{
    // MARK: - Size
    
    public var linesOfCode: Int?
    public var linesOfCodeOfParts: Int?
    public var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    public var componentRank: Int?
    public var sccIndexTopologicallySorted: Int?
    public var ingoingDependenciesInScope: Int?
    public var outgoingDependenciesInScope: Int?
    
    // MARK: - Qualitative Metrics
    
    public var isInACycle: Bool?
    public var linesOfCodeOfPartsInCycles: Int?
}
