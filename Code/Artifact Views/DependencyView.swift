import SwiftUI
import SwiftyToolz
import CodefaceCore

struct DependencyView: View
{
    var body: some View
    {
        Arrow(from: sourcePoint, to: targetPoint, size: size)
            .stroke(style: .init(lineWidth: size / 3, lineCap: .round))
            .foregroundColor(color)
    }
    
    private var color: SwiftUI.Color
    {
        isHighlighted ? .accentColor : isPartOfCycle ? warningRed : Color(white: defaultBrightness)
    }
    
    private var warningRed: SwiftUI.Color
    {
        Color(.dynamic(lightMode: .rgba(0.95, 0, 0, 0.75), darkMode: .rgba(1, 0, 0, 0.75)))
    }
    
    private var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
    private var isPartOfCycle: Bool
    {
        let sourceSCCIndex = source.codeArtifact.metrics.sccIndexTopologicallySorted
        let targetSCCIndex = target.codeArtifact.metrics.sccIndexTopologicallySorted
        
        return sourceSCCIndex == targetSCCIndex
    }
    
//    func calculateOpacity() -> Double { 1 - pow(0.5, weight) }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
    
    let sourcePoint, targetPoint: CGPoint
    
    let weight: Double
    
    let defaultBrightness: Double
    
    let size: Double
}
