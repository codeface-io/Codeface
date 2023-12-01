import SwiftUIToolzOLD
import SwiftUI

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            contentGeometry in
            
            ZStack
            {
                ForEach(artifactVM.partDependencies)
                {
                    dependencyVM in
                    
                    DependencyView(source: dependencyVM.sourcePart,
                                   target: dependencyVM.targetPart,
                                   viewModel: dependencyVM,
                                   defaultBrightness: lineBrightness(forBGBrightness: partBGBrightness,
                                                                     isDarkMode: colorScheme == .dark),
                                   size: (artifactVM.gapBetweenParts ?? 0) / 2.5)
                    .opacity(dependencyVM.sourcePart.passesSearchFilter && dependencyVM.targetPart.passesSearchFilter ? 1 : 0)
                }
                
                ForEach(artifactVM.parts)
                {
                    partVM in
                    
                    ArtifactView(bgBrightness: partBGBrightness,
                                 artifactVM: partVM,
                                 pathBar: pathBar,
                                 ignoreSearchFilter: ignoreSearchFilter)
                    .opacity(partVM.passesSearchFilter ? 1 : 0)
                }
            }
            .frame(width: contentGeometry.size.width,
                   height: contentGeometry.size.height)
        }
    }
    
    private var partBGBrightness: Double
    {
        (bgBrightness + 0.1).clampedToFactor()
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let pathBar: PathBar
    let ignoreSearchFilter: Bool
    let bgBrightness: Double
    @Environment(\.colorScheme) var colorScheme
}
