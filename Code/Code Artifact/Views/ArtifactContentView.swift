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
                            let originPoint = dependentVM.connectionPoint(to: partVM)
                            let destinationPoint = partVM.connectionPoint(to: dependentVM)
                            
                            Line(from: originPoint, to: destinationPoint)
                            .stroke()
                            .foregroundColor(artifactVM.showsContent ? .secondary : .clear)
                            
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                                .position(originPoint)
                            
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.green)
                                .position(destinationPoint)
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
        let x = otherArtifact.frameInScopeContent.x > frameInScopeContent.maxX ? frameInScopeContent.maxX : (otherArtifact.frameInScopeContent.maxX < frameInScopeContent.x ? frameInScopeContent.x : frameInScopeContent.centerX)
        
        let y = otherArtifact.frameInScopeContent.y > frameInScopeContent.maxY ? frameInScopeContent.maxY : (otherArtifact.frameInScopeContent.maxY < frameInScopeContent.y ? frameInScopeContent.y : frameInScopeContent.centerY)
        
        return CGPoint(x: x, y: y)
    }
}
