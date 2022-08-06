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
                        dependingVM in

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

extension ArtifactViewModel
{
    func pointsForDependency(to otherArtifact: ArtifactViewModel) -> (CGPoint, CGPoint)
    {
        let myFrame = frameInScopeContent
        let otherFrame = otherArtifact.frameInScopeContent
        
        let x1, y1, x2, y2: Double
        
        // x-axis
        if otherFrame.x > myFrame.maxX { // other is to the right
            x1 = myFrame.maxX
            x2 = otherFrame.x
        } else if otherFrame.maxX < myFrame.x { // other is to the left
            x1 = myFrame.x
            x2 = otherFrame.maxX
        } else { // other is horizontally overlapping (above or below)
            x1 = pointOnLine(from: max(otherFrame.x, myFrame.x),
                             to: min(otherFrame.maxX, myFrame.maxX))
            x2 = x1
        }
        
        // y-axis
        if otherFrame.y > myFrame.maxY { // other is below
            y1 = myFrame.maxY
            y2 = otherFrame.y
        } else if otherFrame.maxY < myFrame.y { // other is above
            y1 = myFrame.y
            y2 = otherFrame.maxY
        } else { // other is vertically overlapping (to the left or right)
            y1 = pointOnLine(from: max(otherFrame.y, myFrame.y),
                             to: min(otherFrame.maxY, myFrame.maxY))
            y2 = y1
        }
        
        return (CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2))
    }
    
    func pointOnLine(from a: Double, to b: Double) -> Double
    {
        a + ((b - a) * 0.5) // (0.25 + .random(in: 0 ... 0.5)))
    }
}
