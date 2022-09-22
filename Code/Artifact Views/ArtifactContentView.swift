import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct ArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            contentGeometry in
            
            ZStack
            {
                ForEach(artifactVM.filteredPartDependencies)
                {
                    dependencyVM in
                    
                    DependencyView(source: dependencyVM.sourcePart,
                                   target: dependencyVM.targetPart,
                                   viewModel: dependencyVM,
                                   defaultBrightness: lineBrightness(forBGBrightness: partBGBrightness,
                                                                     isDarkMode: colorScheme == .dark),
                                   size: artifactVM.gapBetweenParts / 2.5)
                }
                
                ForEach(artifactVM.filteredParts)
                {
                    partVM in
                    
                    ArtifactView(artifactVM: partVM,
                                 pathBar: pathBar,
                                 ignoreSearchFilter: ignoreSearchFilter,
                                 bgBrightness: partBGBrightness)
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
