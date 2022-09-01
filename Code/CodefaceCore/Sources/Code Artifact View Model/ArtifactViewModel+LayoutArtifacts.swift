import Foundation
import SwiftyToolz

public extension ArtifactViewModel
{
    func updateLayoutOfParts(forScopeSize scopeSize: CGSize,
                             ignoreSearchFilter: Bool)
    {
        let presentedParts = ignoreSearchFilter ? parts : filteredParts
        
        guard !presentedParts.isEmpty else
        {
            showsContent = false
            return
        }
        
        gapBetweenParts = pow(scopeSize.width * scopeSize.height, (1 / 6.0)) * 2
        
        showsContent = prepare(parts: presentedParts,
                               forLayoutIn: .init(x: 0,
                                                  y: 0,
                                                  width: scopeSize.width,
                                                  height: scopeSize.height),
                               ignoreSearchFilter: ignoreSearchFilter)
    }
    
    @discardableResult
    private func prepare(parts: [ArtifactViewModel],
                         forLayoutIn availableRect: CGRect,
                         ignoreSearchFilter: Bool) -> Bool
    {
        if parts.isEmpty { return false }
        
        // base case
        if parts.count == 1
        {
            let part = parts[0]
            
            part.frameInScopeContent = .init(centerX: availableRect.midX,
                                             centerY: availableRect.midY,
                                             width: availableRect.width,
                                             height: availableRect.height)
            
            if availableRect.width > 100, availableRect.height > 100
            {
                let padding = ArtifactViewModel.padding
                let headerHeight = part.fontSize + 2 * padding
                
                part.contentFrame = .init(x: padding,
                                          y: headerHeight,
                                          width: availableRect.width - (2 * padding),
                                          height: (availableRect.height - padding) - headerHeight)
            }
            else
            {
                part.contentFrame = .init(x: availableRect.width / 2,
                                          y: availableRect.height / 2,
                                          width: 0,
                                          height: 0)
            }
            
            part.updateLayoutOfParts(forScopeSize: .init(width: part.contentFrame.width,
                                                         height: part.contentFrame.height),
                                     ignoreSearchFilter: ignoreSearchFilter)
            
            return availableRect.size.width >= ArtifactViewModel.minWidth &&
            availableRect.size.height >= ArtifactViewModel.minHeight
        }
        
        // tree map algorithm
        let (partsA, partsB) = split(parts)
        
        let lastComponentA = partsA.last?.codeArtifact.metrics.componentRank
        let firstComponentB = partsB.first?.codeArtifact.metrics.componentRank
        let isSplitBetweenComponents = lastComponentA == nil || firstComponentB == nil || lastComponentA != firstComponentB
        
        let locA = partsA.sum { $0.codeArtifact.linesOfCode }
        let locB = partsB.sum { $0.codeArtifact.linesOfCode }
        
        let fractionA = Double(locA) / Double(locA + locB)
        
        let bigGap = 3 * gapBetweenParts
        
        let properRectSplit = split(availableRect,
                                    firstFraction: fractionA,
                                    gap: isSplitBetweenComponents ? gapBetweenParts : bigGap)
        
        let rectSplitToUse = properRectSplit ?? forceSplit(availableRect)
        
        let successA = prepare(parts: partsA,
                               forLayoutIn: rectSplitToUse.0,
                               ignoreSearchFilter: ignoreSearchFilter)
        
        let successB = prepare(parts: partsB,
                               forLayoutIn: rectSplitToUse.1,
                               ignoreSearchFilter: ignoreSearchFilter)
        
        return properRectSplit != nil && successA && successB
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
        
        let halfTotalLOC = (parts.sum { $0.codeArtifact.linesOfCode }) / 2
        
        var partsALOC = 0
        var minDifferenceToHalfTotalLOC = Int.max
        var optimalEndIndexForPartsA = 0
        
        for index in 0 ..< parts.count
        {
            // if parts span multiple components, we only cut between components
            if partsSpanMultipleComponents
            {
                if index == parts.count - 1 { continue }
                
                let thisPartComponent = parts[index].codeArtifact.metrics.componentRank
                let nextPartComponent = parts[index + 1].codeArtifact.metrics.componentRank
                let indexIsEndOfComponent = thisPartComponent != nextPartComponent
                
                if !indexIsEndOfComponent { continue }
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
    
    func split(_ rect: CGRect,
               firstFraction: Double,
               gap: Double) -> (CGRect, CGRect)?
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
    
    func forceSplit(_ rect: CGRect) -> (CGRect, CGRect)
    {
        if rect.width / rect.height > 1
        {
            let padding = rect.width > ArtifactViewModel.padding ? ArtifactViewModel.padding : 0
            
            let width = (rect.width - padding) / 2
            
            return (CGRect(x: rect.minX,
                           y: rect.minY,
                           width: width,
                           height: rect.height),
                    CGRect(x: rect.minX + width + padding,
                           y: rect.minY,
                           width: width,
                           height: rect.height))
        }
        else
        {
            let padding = rect.height > ArtifactViewModel.padding ? ArtifactViewModel.padding : 0
            
            let height = (rect.height - padding) / 2
            
            return (CGRect(x: rect.minX,
                           y: rect.minY,
                           width: rect.width,
                           height: height),
                    CGRect(x: rect.minX,
                           y: rect.minY + height + padding,
                           width: rect.width,
                           height: height))
        }
    }
    
    func splitIntoLeftAndRight(_ rect: CGRect,
                               firstFraction: Double,
                               gap: Double) -> (CGRect, CGRect)?
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
        
        let rectA = CGRect(x: rect.minX,
                           y: rect.minY,
                           width: widthA,
                           height: rect.height)
        
        let rectB = CGRect(x: (rect.minX + widthA) + gap,
                           y: rect.minY,
                           width: widthB,
                           height: rect.height)
        
        return (rectA, rectB)
    }
    
    func splitIntoTopAndBottom(_ rect: CGRect,
                               firstFraction: Double,
                               gap: Double) -> (CGRect, CGRect)?
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
        
        let rectA = CGRect(x: rect.minX,
                           y: rect.minY,
                           width: rect.width,
                           height: heightA)
        
        let rectB = CGRect(x: rect.minX,
                           y: (rect.minY + heightA) + gap,
                           width: rect.width,
                           height: heightB)
        
        return (rectA, rectB)
    }
}
