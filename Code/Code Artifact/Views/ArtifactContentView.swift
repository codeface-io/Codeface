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
                    
                    ForEach(partVM.incomingDependencies)
                    {
                        dependentVM in

                        if dependentVM.codeArtifact.scope === partVM.codeArtifact.scope
                        {
                            Line(from: .init(x: partVM.frameInScopeContent.centerX,
                                             y: partVM.frameInScopeContent.centerY),
                                 to: .init(x: dependentVM.frameInScopeContent.centerX,
                                           y: dependentVM.frameInScopeContent.centerY))
                            .stroke()
                            .foregroundColor(artifactVM.showsContent ? .secondary : .clear)
                        }
                    }
                }
                
                ForEach(artifactVM.filteredParts)
                {
                    partVM in
                    
                    ArtifactView(artifact: partVM,
                                 viewModel: codeface,
                                 ignoreSearchFilter: ignoreSearchFilter,
                                 bgBrightness: bgBrightness * 1.2)
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
}
