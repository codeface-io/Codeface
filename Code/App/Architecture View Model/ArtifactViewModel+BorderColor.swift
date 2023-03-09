import SwiftyToolz

extension ArtifactViewModel
{
    func borderColor(forBackgroundBrightness bgBrightness: Double) -> UXColor
    {
        if isInFocus { return .system(.accent) }
        
        let errorPortion = metrics.portionOfPartsInCycles
        
        let defaultBorderColor = lineColor(forBGBrightness: bgBrightness)
       
        return .dynamic(defaultBorderColor.mixed(with: errorPortion, of: .red))
    }
}

func lineColor(forBGBrightness bgBrightness: Double) -> DynamicColor
{
    .in(light: .gray(brightness: lineBrightness(forBGBrightness: bgBrightness,
                                                isDarkMode: false)),
        darkness: .gray(brightness: lineBrightness(forBGBrightness: bgBrightness,
                                                   isDarkMode: true)))
}

func lineBrightness(forBGBrightness bgBrightness: Double,
                    isDarkMode: Bool) -> Double
{
    (bgBrightness + (isDarkMode ? 0.2 : -0.4)).clampedToFactor()
}

extension Double
{
    func clampedToFactor() -> Double
    {
        clamped(to: 0 ... 1)
    }
}

extension Comparable
{
    func clamped(to limits: ClosedRange<Self>) -> Self
    {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
