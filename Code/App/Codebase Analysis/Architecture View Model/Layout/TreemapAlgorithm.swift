import SwiftyToolz

enum TreemapAlgorithm
{
    static func split(_ parts: [ArtifactViewModel]) -> ([ArtifactViewModel], [ArtifactViewModel])
    {
        if parts.count == 2 { return ([parts[0]], [parts[1]]) }
        
        if parts.count < 2
        {
            log(error: "Tried to split \(parts.count) remaining parts for tree map")
            return (parts, [])
        }
        
        guard let firstPart = parts.first, let lastPart = parts.last else
        {
            log(error: "Could not get elements from part array \(parts)")
            return (parts, [])
        }
        
        let partsSpanMultipleComponents = firstPart.metrics.componentRank != lastPart.metrics.componentRank
        
        let partsSpanMultipleSCCs = firstPart.metrics.sccIndexTopologicallySorted != lastPart.metrics.sccIndexTopologicallySorted
        
        let halfTotalLOC = (parts.sum { $0.metrics.linesOfCode ?? 0 }) / 2
        
        var partsALOC = 0
        var minDifferenceToHalfTotalLOC = Int.max
        var optimalEndIndexForPartsA = 0
        
        for index in 0 ..< parts.count
        {
            let part = parts[index]
            partsALOC += part.metrics.linesOfCode ?? 0
            
            if partsSpanMultipleComponents
            {
                // if parts span multiple components, we only cut between components
                if index == parts.count - 1 { continue }
                
                let thisPartComponent = parts[index].metrics.componentRank
                let nextPartComponent = parts[index + 1].metrics.componentRank
                let indexIsEndOfComponent = thisPartComponent != nextPartComponent
                
                if !indexIsEndOfComponent { continue }
            }
            else if partsSpanMultipleSCCs
            {
                // if parts span multiple SCCs, we only cut between SCCs
                if index == parts.count - 1 { continue }
                
                let thisPartSCC = parts[index].metrics.sccIndexTopologicallySorted
                let nextPartSCC = parts[index + 1].metrics.sccIndexTopologicallySorted
                let indexIsEndOfSCC = thisPartSCC != nextPartSCC
                
                if !indexIsEndOfSCC { continue }
            }
            
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
    
    static func split(_ rect: Rectangle,
                      firstFraction: Double,
                      gap: Double,
                      minimumSize: Size) -> (Rectangle, Rectangle)?
    {
        let smallestPossibleResultingWidth = (rect.width - gap) * min(firstFraction, 1 - firstFraction)
        let leftRightSplitWouldSuck = smallestPossibleResultingWidth < 200
        let rectAspectRatio = rect.width / rect.height
        let tryLeftRightSplitFirst = leftRightSplitWouldSuck ? false : rectAspectRatio > 1
        
        if tryLeftRightSplitFirst
        {
            let result = splitIntoLeftAndRight(rect,
                                               firstFraction: firstFraction,
                                               gap: gap,
                                               minWidth: minimumSize.width)
            
            return result ?? splitIntoTopAndBottom(rect,
                                                   firstFraction: firstFraction,
                                                   gap: gap,
                                                   minHeight: minimumSize.height)
        }
        else
        {
            let result = splitIntoTopAndBottom(rect,
                                               firstFraction: firstFraction,
                                               gap: gap,
                                               minHeight: minimumSize.height)
            
            return result ?? splitIntoLeftAndRight(rect,
                                                   firstFraction: firstFraction,
                                                   gap: gap,
                                                   minWidth: minimumSize.width)
        }
    }
    
    private static func splitIntoLeftAndRight(_ rect: Rectangle,
                                              firstFraction: Double,
                                              gap: Double,
                                              minWidth: Double) -> (Rectangle, Rectangle)?
    {
        if 2 * minWidth + gap > rect.width
        {
            return nil
        }
        
        var widthA = (rect.width - gap) * firstFraction
        var widthB = (rect.width - widthA) - gap
        
        if widthA < minWidth
        {
            widthA = minWidth
            widthB = (rect.width - minWidth) - gap
        }
        else if widthB < minWidth
        {
            widthB = minWidth
            widthA = (rect.width - minWidth) - gap
        }
        
        let rectA = Rectangle(position: rect.position,
                              size: Size(widthA, rect.height))
        
        let rectB = Rectangle(position: Point((rect.x + widthA) + gap, rect.y),
                              size: Size(widthB, rect.height))
        
        return (rectA, rectB)
    }
    
    private static func splitIntoTopAndBottom(_ rect: Rectangle,
                                              firstFraction: Double,
                                              gap: Double,
                                              minHeight: Double) -> (Rectangle, Rectangle)?
    {
        if 2 * minHeight + gap > rect.height
        {
            return nil
        }
        
        var heightA = (rect.height - gap) * firstFraction
        var heightB = (rect.height - heightA) - gap
        
        if heightA < minHeight
        {
            heightA = minHeight
            heightB = (rect.height - minHeight) - gap
        }
        else if heightB < minHeight
        {
            heightB = minHeight
            heightA = (rect.height - minHeight) - gap
        }
        
        let rectA = Rectangle(position: rect.position,
                              size: Size(rect.width, heightA))
        
        let rectB = Rectangle(position: Point(rect.x, (rect.y + heightA) + gap),
                              size: Size(rect.width, heightB))
        
        return (rectA, rectB)
    }
}
