import SwiftUI
import SwiftyToolz
import CodefaceCore

struct DependencyView: View
{
    var body: some View
    {
        Arrow(from: CGPoint(viewModel.sourcePoint),
              to: CGPoint(viewModel.targetPoint),
              size: size)
            .stroke(style: .init(lineWidth: size / 3, lineCap: .round))
            .foregroundColor(Color(color))
    }
    
    private var color: UXColor
    {
        if isHighlighted
        {
            return .dynamic(CodefaceStyle.accent.mixed(with: isPartOfCycle ? 0.5 : 0,
                                                       of: CodefaceStyle.warningRed))
        }
        else
        {
            return isPartOfCycle ? .dynamic(CodefaceStyle.warningRed) : .rgba(.gray(brightness: defaultBrightness))
        }
    }
    
    private var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
    private var isPartOfCycle: Bool
    {
        let sourceSCCIndex = source.codeArtifact.metrics.sccIndexTopologicallySorted
        let targetSCCIndex = target.codeArtifact.metrics.sccIndexTopologicallySorted
        
        return sourceSCCIndex == targetSCCIndex
    }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
    
    @ObservedObject var viewModel: DependencyVM
    
    let defaultBrightness: Double
    let size: Double
}
