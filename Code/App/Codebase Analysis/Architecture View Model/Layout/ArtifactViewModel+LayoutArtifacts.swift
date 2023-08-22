import FoundationToolz
import Foundation
import SwiftyToolz

extension ArtifactViewModel
{
    func layoutParts(in availableSize: Size,
                     ignoreSearchFilter: Bool)
    {
        let shownParts = ignoreSearchFilter ? parts : filteredParts
        
        if shownParts.isEmpty
        {
            showsParts = false
            return
        }
        
        gapBetweenParts = 2 * pow(availableSize.surface, (1 / 6.0))
        
        showsParts = layout(shownParts,
                            in: Rectangle(size: availableSize),
                            ignoreSearchFilter: ignoreSearchFilter)
        
        // TODO: this is correct but partly redundant. make sure we zero the layout of each hidden part only once, in particular avoid redundant recursive tree traversals
        if !(showsParts ?? false)
        {
            layout(hiddenParts: parts, in: availableSize)
        }
    }
    
    @discardableResult
    private func layout(_ parts: [ArtifactViewModel],
                        in availableRect: Rectangle,
                        ignoreSearchFilter: Bool) -> Bool
    {
        // sanity check
        if parts.isEmpty
        {
            log(error: "\(#function) called with empty array of parts. This is unexpected.")
            return false
        }
        
        // base case of treemap algorithm
        if parts.count == 1
        {
            return layout(parts[0],
                          in: availableRect,
                          ignoreSearchFilter: ignoreSearchFilter)
        }
        
        // recursive case of treemap algorithm
        let (partsA, partsB) = TreemapAlgorithm.split(parts)
        
        let lastComponentA = partsA.last?.metrics.componentRank
        let firstComponentB = partsB.first?.metrics.componentRank
        let isSplitBetweenComponents = lastComponentA == nil || firstComponentB == nil || lastComponentA != firstComponentB
        
        let locA = partsA.sum { $0.metrics.linesOfCode ?? 0 }
        let locB = partsB.sum { $0.metrics.linesOfCode ?? 0 }
        
        let fractionA = Double(locA) / Double(locA + locB)
        
        let regularGap = gapBetweenParts ?? 0
        let bigGap = 3 * regularGap
        
        guard let rectSplit = TreemapAlgorithm.split(availableRect,
                                                     firstFraction: fractionA,
                                                     gap: isSplitBetweenComponents ? regularGap : bigGap,
                                                     minimumSize: ArtifactViewModel.minimumSize)
        else
        {
            if GlobalSettings.shared.useCorrectAnimations
            {
                layout(hiddenParts: parts,
                       in: availableRect.size)
            }
            
            return false
        }
        
        let partsACanBeShown = layout(partsA,
                                      in: rectSplit.0,
                                      ignoreSearchFilter: ignoreSearchFilter)
        
        if !partsACanBeShown && !GlobalSettings.shared.useCorrectAnimations
        {
            return false
        }
        
        let partsBCanBeShown = layout(partsB,
                                      in: rectSplit.1,
                                      ignoreSearchFilter: ignoreSearchFilter)
        
        return partsACanBeShown && partsBCanBeShown
    }
    
    private func layout(_ part: ArtifactViewModel,
                        in availableRect: Rectangle,
                        ignoreSearchFilter: Bool) -> Bool
    {
        part.frameInScopeContent = availableRect
        
        let padding = ArtifactViewModel.padding
        let headerHeight = part.fontSize + 2 * padding
        let contenFrameSize = Size(availableRect.width - (2 * padding),
                                   (availableRect.height - padding) - headerHeight)
        
        if contenFrameSize > ArtifactViewModel.minimumSize
        {
            part.contentFrame = Rectangle(position: Point(padding, headerHeight),
                                          size: contenFrameSize)
            
            part.layoutParts(in: contenFrameSize,
                             ignoreSearchFilter: ignoreSearchFilter)
        }
        else
        {
            part.showsParts = false
            
            if GlobalSettings.shared.useCorrectAnimations
            {
                part.contentFrame = Rectangle(position: availableRect.size / 2)
                
                layout(hiddenParts: part.parts)
            }
        }
        
        return availableRect.size >= ArtifactViewModel.minimumSize
    }
    
    private func layout(hiddenParts parts: [ArtifactViewModel],
                        in availableSize: Size = .zero)
    {
        let centerPointFrame = Rectangle(position: availableSize / 2)
        
        for part in parts
        {
            part.frameInScopeContent = centerPointFrame
            part.contentFrame = .zero
            
            layout(hiddenParts: part.parts)
        }
    }
}

extension SIMD2: Comparable where Scalar: Comparable
{
    public static func < (lhs: SIMD2<Scalar>,
                          rhs: SIMD2<Scalar>) -> Bool
    {
        lhs.x < rhs.x && lhs.y < rhs.y
    }
}
