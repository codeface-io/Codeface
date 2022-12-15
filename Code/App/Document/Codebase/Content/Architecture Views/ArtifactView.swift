import SwiftUI
import CodefaceCore
import SwiftLSP
import SwiftyToolz

struct ArtifactView: View
{
    var body: some View
    {
        ZStack
        {
            ArtifactHeaderView(artifactVM: artifactVM)
                .framePosition(artifactVM.headerFrame)
            
            if artifactVM.showsContent
            {
                ArtifactContentView(artifactVM: artifactVM,
                                    pathBar: pathBar,
                                    ignoreSearchFilter: ignoreSearchFilter,
                                    bgBrightness: bgBrightness)
                .framePosition(artifactVM.contentFrame)
            }
        }
        .onHover
        {
            if $0
            {
                artifactVM.isInFocus = true
                pathBar.add(artifactVM)
            }
            else
            {
                withAnimation(.easeInOut)
                {
                    artifactVM.isInFocus = false
                    pathBar.remove(artifactVM)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor)
            .opacity(artifactVM.containsSearchTermRegardlessOfParts ?? false ? colorScheme == .dark ? 1 : 0.2 : 0)
            .blendMode(colorScheme == .dark ? .multiply : .normal)
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(Color(borderColor(for: colorScheme)),
                              lineWidth: 1,
                              antialiased: true)))
        .background(RoundedRectangle(cornerRadius: 5)
            .fill(Color(white: bgBrightness).opacity(0.9)))
        .framePosition(artifactVM.frameInScopeContent)
    }
    
    private func borderColor(for colorScheme: ColorScheme) -> UXColor
    {
        if artifactVM.isInFocus { return .system(.accent) }
        
        let errorPortion = artifactVM.codeArtifact.metrics.portionOfPartsInCycles
        
        return .dynamic(defaultBorderColor.mixed(with: errorPortion, of: CodefaceStyle.warningRed))
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let pathBar: PathBar
    let ignoreSearchFilter: Bool
    let bgBrightness: Double
    
    private var defaultBorderColor: DynamicColor
    {
        lineColor(forBGBrightness: bgBrightness)
    }
    
    @Environment(\.colorScheme) private var colorScheme
}

func lineColor(forBGBrightness bgBrightness: Double) -> DynamicColor
{
    .in(light: .gray(brightness: lineBrightness(forBGBrightness: bgBrightness, isDarkMode: false)),
        darkness: .gray(brightness: lineBrightness(forBGBrightness: bgBrightness, isDarkMode: true)))
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
