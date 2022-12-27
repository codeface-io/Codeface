public struct Metrics: Sendable
{
    // MARK: - Qualitative Metrics
    
    public lazy var portionOfPartsInCycles: Double = {
        guard let partLOCs = linesOfCodeOfParts, partLOCs > 0,
              let partLOCsInCycles = linesOfCodeOfPartsInCycles
        else { return 0 }
        
        return Double(partLOCsInCycles) / Double(partLOCs)
    }()
    
    public var linesOfCodeInCycles: Int
    {
        isInACycle ?? false ? linesOfCode ?? 0 : linesOfCodeOfPartsInCycles ?? 0
    }
    
    public var isInACycle: Bool?
    public var linesOfCodeOfPartsInCycles: Int?
    
    // MARK: - Size
    
    public var linesOfCode: Int?
    public var linesOfCodeOfParts: Int?
    public var sizeRelativeToAllPartsInScope: Double?
    
    // MARK: - Dependency "Ranking"
    
    public var componentRank: Int?
    public var sccIndexTopologicallySorted: Int?
}
