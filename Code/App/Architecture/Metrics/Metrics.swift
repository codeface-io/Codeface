struct Metrics: Sendable
{
    // MARK: - Cycle Metrics
    
    var portionOfPartsInCycles: Double
    {
        guard let partLOCs = linesOfCodeOfParts, partLOCs > 0,
              let partLOCsInCycles = linesOfCodeOfPartsInCycles
        else { return 0 }
        
        return Double(partLOCsInCycles) / Double(partLOCs)
    }
    
    var linesOfCodeInCycles: Int
    {
        isInACycle ?? false ? linesOfCode ?? 0 : linesOfCodeOfPartsInCycles ?? 0
    }
    
    var isInACycle: Bool?
    var linesOfCodeOfPartsInCycles: Int?
    
    // MARK: - Sort Rank
    
    var sortRank: Int = 0
    
    // MARK: - Size
    
    var linesOfCode: Int?
    var linesOfCodeOfParts: Int?
    var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    var componentRank: Int?
    var sccIndexTopologicallySorted: Int?
}
