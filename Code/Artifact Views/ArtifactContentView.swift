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
                            .stroke(style: .init(lineWidth: 3, lineCap: .round))
                            .foregroundColor(artifactVM.showsContent ? .primary.opacity(0.5) : .clear)
                        }
                    }
                }
                
                ForEach(artifactVM.filteredParts)
                {
                    partVM in
                    
                    ArtifactView(artifactVM: partVM,
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
        let x = otherArtifact.frameInScopeContent.x > frameInScopeContent.maxX ? frameInScopeContent.maxX : (otherArtifact.frameInScopeContent.maxX < frameInScopeContent.x ? frameInScopeContent.x : (max(otherArtifact.frameInScopeContent.x, frameInScopeContent.x) + min(otherArtifact.frameInScopeContent.maxX, frameInScopeContent.maxX)) / 2)
        
        let y = otherArtifact.frameInScopeContent.y > frameInScopeContent.maxY ? frameInScopeContent.maxY : (otherArtifact.frameInScopeContent.maxY < frameInScopeContent.y ? frameInScopeContent.y : (max(otherArtifact.frameInScopeContent.y, frameInScopeContent.y) + min(otherArtifact.frameInScopeContent.maxY, frameInScopeContent.maxY)) / 2)
        
        return CGPoint(x: x, y: y)
    }
}
