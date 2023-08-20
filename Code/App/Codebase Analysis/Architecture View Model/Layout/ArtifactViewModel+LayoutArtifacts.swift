import FoundationToolz
import Foundation
import SwiftyToolz

extension ArtifactViewModel
{
    func updateLayoutOfParts(forScopeSize scopeSize: Size,
                             ignoreSearchFilter: Bool)
    {
        lastLayoutConfiguration = .init(ignoreFilter: ignoreSearchFilter,
                                        scopeContentSize: scopeSize)
        
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
            
            let padding = ArtifactViewModel.padding
            let headerHeight = part.fontSize + 2 * padding
            let contenFrameSize = Size(availableRect.width - (2 * padding),
                                       (availableRect.height - padding) - headerHeight)
            
            if contenFrameSize.width > ArtifactViewModel.minimumSize.width,
               contenFrameSize.height > ArtifactViewModel.minimumSize.height
            {
                part.contentFrame = Rectangle(position: Point(padding, headerHeight),
                                              size: contenFrameSize)
                
                part.updateLayoutOfParts(forScopeSize: contenFrameSize,
                                         ignoreSearchFilter: ignoreSearchFilter)
            }
            else
            {
                part.showsContent = false
                
                if GlobalSettings.shared.useCorrectAnimations
                {
                    part.contentFrame = Rectangle(position: Point(availableRect.width / 2,
                                                                  availableRect.height / 2))
                    
                    setDefaultLayout(forHiddenParts: part.parts)
                }
            }
            
            return availableRect.width >= ArtifactViewModel.minimumSize.width &&
            availableRect.height >= ArtifactViewModel.minimumSize.height
        }
        
        // tree map algorithm
        let (partsA, partsB) = split(parts)
        
        let lastComponentA = partsA.last?.metrics.componentRank
        let firstComponentB = partsB.first?.metrics.componentRank
        let isSplitBetweenComponents = lastComponentA == nil || firstComponentB == nil || lastComponentA != firstComponentB
        
        let locA = partsA.sum { $0.metrics.linesOfCode ?? 0 }
        let locB = partsB.sum { $0.metrics.linesOfCode ?? 0 }
        
        let fractionA = Double(locA) / Double(locA + locB)
        
        let regularGap = gapBetweenParts ?? 0
        let bigGap = 3 * regularGap
        
        if let rectSplit = TreemapAlgorithm.split(availableRect,
                                                  firstFraction: fractionA,
                                                  gap: isSplitBetweenComponents ? regularGap : bigGap,
                                                  minimumSize: ArtifactViewModel.minimumSize)
        {
            let partsACanBeShown = prepare(parts: partsA,
                                           forLayoutIn: rectSplit.0,
                                           ignoreSearchFilter: ignoreSearchFilter)
            
            if !partsACanBeShown && !GlobalSettings.shared.useCorrectAnimations { return false }
            
            let partsBCanBeShown = prepare(parts: partsB,
                                           forLayoutIn: rectSplit.1,
                                           ignoreSearchFilter: ignoreSearchFilter)
            
            return partsACanBeShown && partsBCanBeShown
        }
        else
        {
            if GlobalSettings.shared.useCorrectAnimations
            {
                setDefaultLayout(forHiddenParts: parts,
                                 inAvailableRect: availableRect)
            }
            
            return false
        }
    }
    
    private func setDefaultLayout(forHiddenParts parts: [ArtifactViewModel],
                                  inAvailableRect availableRect: Rectangle = .zero)
    {
        for part in parts
        {
            part.frameInScopeContent = availableRect
            
            if availableRect == .zero
            {
                part.contentFrame = .zero
            }
            else
            {
                part.contentFrame = Rectangle(position: Point(availableRect.width / 2,
                                                              availableRect.height / 2))
            }
            
            setDefaultLayout(forHiddenParts: part.parts)
        }
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
}
