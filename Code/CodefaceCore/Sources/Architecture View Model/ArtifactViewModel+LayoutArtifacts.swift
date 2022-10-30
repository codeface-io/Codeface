import FoundationToolz
import Foundation
import SwiftyToolz

public extension ArtifactViewModel
{
    func updateLayoutOfParts(forScopeSize scopeSize: Size,
                             ignoreSearchFilter: Bool)
    {
        let shownContentParts = ignoreSearchFilter ? parts : filteredParts
        
        guard !shownContentParts.isEmpty else
        {
            showsContent = false
            return
        }
        
        gapBetweenParts = 2 * pow(scopeSize.width * scopeSize.height, (1 / 6.0))
        
        showsContent = prepare(parts: shownContentParts,
                               forLayoutIn: Rectangle(size: scopeSize),
                               ignoreSearchFilter: ignoreSearchFilter)
    }
    
    @discardableResult
    private func prepare(parts: [ArtifactViewModel],
                         forLayoutIn availableRect: Rectangle,
                         ignoreSearchFilter: Bool) -> Bool
    {
        if parts.isEmpty { return false }
        
        // base case
        if parts.count == 1
        {
            let part = parts[0]
            
            part.frameInScopeContent = availableRect
            
            if availableRect.width > 100, availableRect.height > 100
            {
                let padding = ArtifactViewModel.padding
                let headerHeight = part.fontSize + 2 * padding
                
                part.contentFrame = Rectangle(position: Point(padding, headerHeight),
                                              size: Size(availableRect.width - (2 * padding),
                                                         (availableRect.height - padding) - headerHeight))
            }
            else
            {
                part.contentFrame = Rectangle(position: Point(availableRect.width / 2,
                                                              availableRect.height / 2))
            }
            
            part.updateLayoutOfParts(forScopeSize: .init(width: part.contentFrame.width,
                                                         height: part.contentFrame.height),
                                     ignoreSearchFilter: ignoreSearchFilter)
            
            return availableRect.width >= ArtifactViewModel.minWidth &&
            availableRect.height >= ArtifactViewModel.minHeight
        }
        
        // tree map algorithm
        let (partsA, partsB) = split(parts)
        
        let lastComponentA = partsA.last?.codeArtifact.metrics.componentRank
        let firstComponentB = partsB.first?.codeArtifact.metrics.componentRank
        let isSplitBetweenComponents = lastComponentA == nil || firstComponentB == nil || lastComponentA != firstComponentB
        
        let locA = partsA.sum { $0.codeArtifact.linesOfCode }
        let locB = partsB.sum { $0.codeArtifact.linesOfCode }
        
        let fractionA = Double(locA) / Double(locA + locB)
        
        let regularGap = gapBetweenParts ?? 0
        let bigGap = 3 * regularGap
        
        guard let rectSplit = split(availableRect,
                                    firstFraction: fractionA,
                                    gap: isSplitBetweenComponents ? regularGap : bigGap),
              prepare(parts: partsA,
                      forLayoutIn: rectSplit.0,
                      ignoreSearchFilter: ignoreSearchFilter),
              prepare(parts: partsB,
                      forLayoutIn: rectSplit.1,
                      ignoreSearchFilter: ignoreSearchFilter) else { return false }

        return true
    }
    
    func split(_ parts: [ArtifactViewModel]) -> ([ArtifactViewModel], [ArtifactViewModel])
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
        
        let partsSpanMultipleComponents = firstPart.codeArtifact.metrics.componentRank != lastPart.codeArtifact.metrics.componentRank
        
        let partsSpanMultipleSCCs = firstPart.codeArtifact.metrics.sccIndexTopologicallySorted != lastPart.codeArtifact.metrics.sccIndexTopologicallySorted
        
        let halfTotalLOC = (parts.sum { $0.codeArtifact.linesOfCode }) / 2
        
        var partsALOC = 0
        var minDifferenceToHalfTotalLOC = Int.max
        var optimalEndIndexForPartsA = 0
        
        for index in 0 ..< parts.count
        {
            if partsSpanMultipleComponents
            {
                // if parts span multiple components, we only cut between components
                if index == parts.count - 1 { continue }
                
                let thisPartComponent = parts[index].codeArtifact.metrics.componentRank
                let nextPartComponent = parts[index + 1].codeArtifact.metrics.componentRank
                let indexIsEndOfComponent = thisPartComponent != nextPartComponent
                
                if !indexIsEndOfComponent { continue }
            }
            else if partsSpanMultipleSCCs
            {
                // if parts span multiple SCCs, we only cut between SCCs
                if index == parts.count - 1 { continue }
                
                let thisPartSCC = parts[index].codeArtifact.metrics.sccIndexTopologicallySorted
                let nextPartSCC = parts[index + 1].codeArtifact.metrics.sccIndexTopologicallySorted
                let indexIsEndOfSCC = thisPartSCC != nextPartSCC
                
                if !indexIsEndOfSCC { continue }
            }
            
            let part = parts[index]
            partsALOC += part.codeArtifact.linesOfCode
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
    
    func split(_ rect: Rectangle,
               firstFraction: Double,
               gap: Double) -> (Rectangle, Rectangle)?
    {
        let smallestPossibleResultingWidth = (rect.width - gap) * min(firstFraction, 1 - firstFraction)
        let leftRightSplitWouldSuck = smallestPossibleResultingWidth < 200
        let rectAspectRatio = rect.width / rect.height
        let tryLeftRightSplitFirst = leftRightSplitWouldSuck ? false : rectAspectRatio > 1
        
        if tryLeftRightSplitFirst
        {
            let result = splitIntoLeftAndRight(rect,
                                               firstFraction: firstFraction,
                                               gap: gap)
            
            return result ?? splitIntoTopAndBottom(rect,
                                                   firstFraction: firstFraction,
                                                   gap: gap)
        }
        else
        {
            let result = splitIntoTopAndBottom(rect,
                                               firstFraction: firstFraction,
                                               gap: gap)
            
            return result ?? splitIntoLeftAndRight(rect,
                                                   firstFraction: firstFraction,
                                                   gap: gap)
        }
    }
    
    func splitIntoLeftAndRight(_ rect: Rectangle,
                               firstFraction: Double,
                               gap: Double) -> (Rectangle, Rectangle)?
    {
        if 2 * ArtifactViewModel.minWidth + gap > rect.width
        {
            return nil
        }
        
        var widthA = (rect.width - gap) * firstFraction
        var widthB = (rect.width - widthA) - gap
        
        if widthA < ArtifactViewModel.minWidth
        {
            widthA = ArtifactViewModel.minWidth
            widthB = (rect.width - ArtifactViewModel.minWidth) - gap
        }
        else if widthB < ArtifactViewModel.minWidth
        {
            widthB = ArtifactViewModel.minWidth
            widthA = (rect.width - ArtifactViewModel.minWidth) - gap
        }
        
        let rectA = Rectangle(position: rect.position,
                              size: Size(widthA, rect.height))
        
        let rectB = Rectangle(position: Point((rect.x + widthA) + gap, rect.y),
                              size: Size(widthB, rect.height))
        
        return (rectA, rectB)
    }
    
    func splitIntoTopAndBottom(_ rect: Rectangle,
                               firstFraction: Double,
                               gap: Double) -> (Rectangle, Rectangle)?
    {
        if 2 * ArtifactViewModel.minHeight + gap > rect.height
        {
            return nil
        }
        
        var heightA = (rect.height - gap) * firstFraction
        var heightB = (rect.height - heightA) - gap
        
        if heightA < ArtifactViewModel.minHeight
        {
            heightA = ArtifactViewModel.minHeight
            heightB = (rect.height - ArtifactViewModel.minHeight) - gap
        }
        else if heightB < ArtifactViewModel.minHeight
        {
            heightB = ArtifactViewModel.minHeight
            heightA = (rect.height - ArtifactViewModel.minHeight) - gap
        }
        
        let rectA = Rectangle(position: rect.position,
                              size: Size(rect.width, heightA))
        
        let rectB = Rectangle(position: Point(rect.x, (rect.y + heightA) + gap),
                              size: Size(rect.width, heightB))
        
        return (rectA, rectB)
    }
}
