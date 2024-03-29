import SwiftUI
import SwiftLSP
import SwiftyToolz
import SwiftUIToolzOLD

struct ArtifactView: View
{
    var body: some View
    {
        ZStack
        {
            ArtifactHeaderView(artifactVM: artifactVM)
                .framePosition(artifactVM.headerFrame)
            
            if GlobalSettings.shared.useCorrectAnimations || artifactVM.showsParts == true
            {
                ArtifactContentView(artifactVM: artifactVM,
                                    pathBar: pathBar,
                                    ignoreSearchFilter: ignoreSearchFilter,
                                    bgBrightness: bgBrightness)
                .framePosition(artifactVM.contentFrame)
                .opacity(artifactVM.showsParts == true ? 1 : 0)
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
        .background(
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(borderColor)
        )
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.accentColor)
                .opacity(artifactVM.containsSearchTermRegardlessOfParts ?? false ? colorScheme == .dark ? 1 : 0.2 : 0)
                .blendMode(colorScheme == .dark ? .multiply : .normal)
        )
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(white: bgBrightness).opacity(0.9))
        )
        .framePosition(artifactVM.frameInScopeContent)
    }
    
    private var borderColor: SwiftUI.Color
    {
        .init(artifactVM.borderColor(forBackgroundBrightness: bgBrightness))
    }
    
    let bgBrightness: Double
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let pathBar: PathBar
    let ignoreSearchFilter: Bool
    
    @Environment(\.colorScheme) private var colorScheme
}
