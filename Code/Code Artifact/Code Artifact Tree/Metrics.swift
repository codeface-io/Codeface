struct Metrics
{
    // MARK: - Size
    
    var linesOfCode: Int?
    var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    var numberOfAllIncomingDependenciesInScope: Int = 0
    var componentNumber: Int?
}
