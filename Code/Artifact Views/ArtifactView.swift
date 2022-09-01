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
            .fill(Color(white: bgBrightness).opacity(0.9))
            .overlay(RoundedRectangle(cornerRadius: 5)
                .strokeBorder(artifactVM.isInFocus ? Color.accentColor : defaultBorderColor,
                              lineWidth: 1,
                              antialiased: true)))
        .framePosition(artifactVM.frameInScopeContent)
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let pathBar: PathBar
    let ignoreSearchFilter: Bool
    let bgBrightness: Double
    let isShownInScope: Bool
    
    private var defaultBorderColor: SwiftUI.Color
    {
        Color(white: lineBrightness(forBGBrightness: bgBrightness,
                                    isDarkMode: colorScheme == .dark))
    }
    
    @Environment(\.colorScheme) private var colorScheme
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
