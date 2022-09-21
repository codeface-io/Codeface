import Darwin
import SwiftyToolz

extension ArtifactViewModel
{
    public func calculateHeaderFrame() -> Frame
    {
        .init(centerX: frameInScopeContent.width / 2 + (calculateExtraSpaceForTitles() / 2),
              centerY: calculateWhetherToCollapseVertically() ? frameInScopeContent.height / 2 : Self.padding + calculateFontSize() / 2,
              width: frameInScopeContent.width - 2 * Self.padding + calculateExtraSpaceForTitles(),
              height: calculateWhetherToCollapseVertically() ? frameInScopeContent.height - 2 * Self.padding : calculateFontSize())
    }
    
    private func calculateExtraSpaceForTitles() -> Double
    {
        calculateWhetherToCollapseHorizontally() ? 0 : 6.0
    }
    
    public func calculateWhetherToShowName() -> Bool
    {
        frameInScopeContent.width - (2 * Self.padding + calculateFontSize()) >= 3 * calculateFontSize()
    }
    
    public func calculateWhetherToCollapseHorizontally() -> Bool
    {
        frameInScopeContent.width <= calculateFontSize() + (2 * Self.padding)
    }
    
    public func calculateWhetherToCollapseVertically() -> Bool
    {
        frameInScopeContent.height <= calculateFontSize() + (2 * Self.padding)
    }
    
    public func calculateFontSize() -> Double
    {
        let viewSurface = frameInScopeContent.height * frameInScopeContent.width
        return 3 * pow(viewSurface, (1 / 6.0))
    }
    
    public static var padding: Double = 16
    
    static var minWidth: Double = 30
    static var minHeight: Double = 30
}
