import SwiftUI
import CodefaceCore

struct DependencyView: View
{
    var body: some View
    {
        Arrow(from: sourcePoint, to: targetPoint, size: size)
            .stroke(style: .init(lineWidth: size / 3, lineCap: .round))
            .foregroundColor(isHighlighted ? .accentColor : Color(white: defaultBrightness))
    }
    
    var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
//    func calculateOpacity() -> Double { 1 - pow(0.5, weight) }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
    
    let sourcePoint, targetPoint: CGPoint
    
    let weight: Double
    
    let defaultBrightness: Double
    
    let size: Double
}
