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
                    
                    // TODO: just give the whole dependencyVM to the DependencyView, making sure that focus updates in source and target still get propagated to the view
                    DependencyView(source: dependencyVM.sourcePart,
                                   target: dependencyVM.targetPart,
                                   sourcePoint: CGPoint(dependencyVM.sourcePoint),
                                   targetPoint: CGPoint(dependencyVM.targetPoint),
                                   weight: Double(dependencyVM.weight),
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
                                 bgBrightness: partBGBrightness,
                                 isShownInScope: isShownInScope && artifactVM.showsContent)
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
    let isShownInScope: Bool
    @Environment(\.colorScheme) var colorScheme
}
