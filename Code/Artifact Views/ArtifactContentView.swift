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
                ForEach(artifactVM.filteredPartDependencies)
                {
                    dependencyVM in
                    
                    // TODO: just give the whole dependencyVM to the DependencyView, making sure that focus updates in source and target still get propagated to the view
                    DependencyView(source: dependencyVM.sourcePart,
                                   target: dependencyVM.targetPart,
                                   sourcePoint: CGPoint(dependencyVM.sourcePoint),
                                   targetPoint: CGPoint(dependencyVM.targetPoint))
                    .opacity(artifactVM.showsContent ? 1 : 0)
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
        Arrow(from: sourcePoint, to: targetPoint)
            .stroke(style: .init(lineWidth: 3, lineCap: .round))
            .foregroundColor(isHighlighted ? .accentColor : .primary.opacity(0.5))
    }
    
    var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
    
    let sourcePoint, targetPoint: CGPoint
}

extension CGPoint
{
    init(_ point: Point)
    {
        self.init(x: point.x, y: point.y)
    }
}
