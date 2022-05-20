import Foundation

extension CodeArtifact
{
    @discardableResult
    func updateLayoutOfParts(forScopeSize scopeSize: CGSize) -> Bool
    {
        guard !parts.isEmpty else { return false }
        
        return prepare(parts: parts,
                       forLayoutIn: .init(x: 0,
                                          y: 0,
                                          width: scopeSize.width,
                                          height: scopeSize.height))
    }
    
    private func prepare(parts: [CodeArtifact],
                         forLayoutIn availableRect: CGRect) -> Bool
    {
        if parts.isEmpty { return false }
        
        if parts.count == 1
        {
            guard availableRect.width >= CodeArtifact.LayoutModel.minWidth,
                  availableRect.height >= CodeArtifact.LayoutModel.minHeight else { return false }
            
            let part = parts[0]
            
            part.layoutModel = .init(width: availableRect.width,
                                     height: availableRect.height,
                                     centerX: availableRect.midX,
                                     centerY: availableRect.midY)
            
            return true
        }
        
        let (partsA, partsB) = split(parts)
        
        let locA = partsA.reduce(0) { $0 + $1.linesOfCode }
        let locB = partsB.reduce(0) { $0 + $1.linesOfCode }
        
        let fractionA = Double(locA) / Double(locA + locB)
        
        guard let (rectA, rectB) = split(availableRect, firstFraction: fractionA) else
        {
            return false
        }
        
        return prepare(parts: partsA, forLayoutIn: rectA)
            && prepare(parts: partsB, forLayoutIn: rectB)
    }
    
    func split(_ parts: [CodeArtifact]) -> ([CodeArtifact], [CodeArtifact])
    {
        let halfTotalLOC = (parts.reduce(0) { $0 + $1.linesOfCode }) / 2
        
        var partsALOC = 0
        var minDifferenceToHalfTotalLOC = Int.max
        var optimalEndIndexForPartsA = 0
        
        for index in 0 ..< parts.count
        {
            let part = parts[index]
            partsALOC += part.linesOfCode
            let differenceToHalfTotalLOC = abs(halfTotalLOC - partsALOC)
            if differenceToHalfTotalLOC < minDifferenceToHalfTotalLOC
            {
                minDifferenceToHalfTotalLOC = differenceToHalfTotalLOC
                optimalEndIndexForPartsA = index
            }
        }
        
        return (Array(parts[0 ... optimalEndIndexForPartsA]),
                Array(parts[optimalEndIndexForPartsA + 1 ..< parts.count]))
    }
    
    func split(_ rect: CGRect,
               firstFraction: Double) -> (CGRect, CGRect)?
    {
        let rectIsSmall = min(rect.width, rect.height) <= CodeArtifact.LayoutModel.minWidth * 5
        let rectAspectRatio = rect.width / rect.height
        let tryLeftRightSplitFirst = rectAspectRatio > (rectIsSmall ? 4 : 2)
        
        if tryLeftRightSplitFirst
        {
            let result = splitIntoLeftAndRight(rect, firstFraction: firstFraction)
            
            return result ?? splitIntoTopAndBottom(rect, firstFraction: firstFraction)
        }
        else
        {
            let result = splitIntoTopAndBottom(rect, firstFraction: firstFraction)
            
            return result ?? splitIntoLeftAndRight(rect, firstFraction: firstFraction)
        }
    }
    
    func splitIntoLeftAndRight(_ rect: CGRect, firstFraction: Double) -> (CGRect, CGRect)?
    {
        if 2 * CodeArtifact.LayoutModel.minWidth + CodeArtifact.LayoutModel.padding > rect.width
        {
            return nil
        }
        
        var widthA = (rect.width - CodeArtifact.LayoutModel.padding) * firstFraction
        var widthB = (rect.width - widthA) - CodeArtifact.LayoutModel.padding
        
        if widthA < CodeArtifact.LayoutModel.minWidth
        {
            widthA = CodeArtifact.LayoutModel.minWidth
            widthB = (rect.width - CodeArtifact.LayoutModel.minWidth) - CodeArtifact.LayoutModel.padding
        }
        else if widthB < CodeArtifact.LayoutModel.minWidth
        {
            widthB = CodeArtifact.LayoutModel.minWidth
            widthA = (rect.width - CodeArtifact.LayoutModel.minWidth) - CodeArtifact.LayoutModel.padding
        }
        
        let rectA = CGRect(x: rect.minX,
                           y: rect.minY,
                           width: widthA,
                           height: rect.height)
        
        let rectB = CGRect(x: (rect.minX + widthA) + CodeArtifact.LayoutModel.padding,
                           y: rect.minY,
                           width: widthB,
                           height: rect.height)
        
        return (rectA, rectB)
    }
    
    func splitIntoTopAndBottom(_ rect: CGRect, firstFraction: Double) -> (CGRect, CGRect)?
    {
        if 2 * CodeArtifact.LayoutModel.minHeight + CodeArtifact.LayoutModel.padding > rect.height
        {
            return nil
        }
        
        var heightA = (rect.height - CodeArtifact.LayoutModel.padding) * firstFraction
        var heightB = (rect.height - heightA) - CodeArtifact.LayoutModel.padding
        
        if heightA < CodeArtifact.LayoutModel.minHeight
        {
            heightA = CodeArtifact.LayoutModel.minHeight
            heightB = (rect.height - CodeArtifact.LayoutModel.minHeight) - CodeArtifact.LayoutModel.padding
        }
        else if heightB < CodeArtifact.LayoutModel.minHeight
        {
            heightB = CodeArtifact.LayoutModel.minHeight
            heightA = (rect.height - CodeArtifact.LayoutModel.minHeight) - CodeArtifact.LayoutModel.padding
        }
        
        let rectA = CGRect(x: rect.minX,
                           y: rect.minY,
                           width: rect.width,
                           height: heightA)
        
        let rectB = CGRect(x: rect.minX,
                           y: (rect.minY + heightA) + CodeArtifact.LayoutModel.padding,
                           width: rect.width,
                           height: heightB)

        return (rectA, rectB)
    }
}

extension CodeArtifact.LayoutModel
{
    var fontSize: Double { 1.2 * sqrt(sqrt(height * width)) }
    
    static var padding: Double = 16
    static var minWidth: Double = 30
    static var minHeight: Double = 30
}
