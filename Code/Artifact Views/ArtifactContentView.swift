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
                ForEach(artifactVM.filteredParts)
                {
                    partVM in
                    
                    ForEach(partVM.incomingDependencies.indices, id: \.self)
                    {
                        let dependingVM = partVM.incomingDependencies[$0]

                        if dependingVM.codeArtifact.scope === partVM.codeArtifact.scope
                        {
                            DependencyView(source: dependingVM, target: partVM)
                                .opacity(artifactVM.showsContent ? 1 : 0)
                        }
                    }
                }
                
                ForEach(artifactVM.filteredParts)
                {
                    partVM in
                    
                    ArtifactView(artifactVM: partVM,
                                 viewModel: codeface,
                                 ignoreSearchFilter: ignoreSearchFilter,
                                 bgBrightness: min(bgBrightness + 0.1, 1),
                                 isShownInScope: isShownInScope && artifactVM.showsContent)
                }
            }
            .frame(width: contentGeometry.size.width,
                   height: contentGeometry.size.height)
        }
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    let codeface: Codeface
    let ignoreSearchFilter: Bool
    let bgBrightness: Double
    let isShownInScope: Bool
    @Environment(\.colorScheme) var colorScheme
}

struct DependencyView: View
{
    var body: some View
    {
        let arrowPoints = source.pointsForDependency(to: target)
        
        Arrow(from: arrowPoints.0, to: arrowPoints.1)
            .stroke(style: .init(lineWidth: 3, lineCap: .round))
            .foregroundColor(isHighlighted ? .accentColor : .primary.opacity(0.5))
    }
    
    var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
}
