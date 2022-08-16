import SwiftUI

struct DependencyView: View
{
    var body: some View
    {
        Arrow(from: sourcePoint, to: targetPoint)
            .stroke(style: .init(lineWidth: 3, lineCap: .round))
            .foregroundColor(isHighlighted ? .accentColor : .primary.opacity(calculateOpacity))
    }
    
    var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
    var calculateOpacity: Double { 1 - pow(0.5, weight) }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
    
    let sourcePoint, targetPoint: CGPoint
    
    let weight: Double
}
