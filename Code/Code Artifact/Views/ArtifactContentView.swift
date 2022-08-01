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
                            Arrow(from: dependentVM.connectionPoint(to: partVM),
                                  to: partVM.connectionPoint(to: dependentVM))
                            .foregroundColor(artifactVM.showsContent ? .primary : .clear)
                        }
                    }
                }
                
                ForEach(artifactVM.filteredParts)
                {
                    partVM in
                    
                    ArtifactView(artifact: partVM,
                                 viewModel: codeface,
                                 ignoreSearchFilter: ignoreSearchFilter,
                                 bgBrightness: min(bgBrightness + 0.1, 1))
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
    @Environment(\.colorScheme) var colorScheme
}

extension ArtifactViewModel
{
    func connectionPoint(to otherArtifact: ArtifactViewModel) -> CGPoint
    {
        let x = otherArtifact.frameInScopeContent.centerX > frameInScopeContent.maxX ? frameInScopeContent.maxX : (otherArtifact.frameInScopeContent.centerX < frameInScopeContent.x ? frameInScopeContent.x : frameInScopeContent.centerX)
        
        let y = otherArtifact.frameInScopeContent.centerY > frameInScopeContent.maxY ? frameInScopeContent.maxY : (otherArtifact.frameInScopeContent.centerY < frameInScopeContent.y ? frameInScopeContent.y : frameInScopeContent.centerY)
        
        return CGPoint(x: x, y: y)
    }
}
