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
            
            ArtifactContentView(artifactVM: artifactVM,
                                pathBar: pathBar,
                                ignoreSearchFilter: ignoreSearchFilter,
                                bgBrightness: bgBrightness,
                                isShownInScope: isShownInScope)
            .framePosition(artifactVM.contentFrame)
            .opacity(artifactVM.showsContent ? 1.0 : 0)
        }
        .onHover
        {
            guard isShownInScope else { return }
            
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
        
        let defaultColor = defaultBorderColor(for: colorScheme)
        let errorPortion = artifactVM.codeArtifact.metrics.portionOfPartsInCycles
        
        return .rgba(defaultColor.mixed(with: errorPortion,
                                        // TODO: use dynamic warning red
                                        of: .rgba(1, 0, 0, 0.75)))
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let pathBar: PathBar
    let ignoreSearchFilter: Bool
    let bgBrightness: Double
    let isShownInScope: Bool
    
    private func defaultBorderColor(for colorScheme: ColorScheme) -> SwiftyToolz.Color
    {
        .gray(brightness: lineBrightness(forBGBrightness: bgBrightness,
                                         isDarkMode: colorScheme == .dark))
    }
    
    @Environment(\.colorScheme) private var colorScheme
}

func lineBrightness(forBGBrightness bgBrightness: Double, isDarkMode: Bool) -> Double
{
    isDarkMode ? (bgBrightness + 0.2).clampedToFactor() : (bgBrightness - 0.4).clampedToFactor()
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
