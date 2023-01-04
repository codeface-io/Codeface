import SwiftUI
import SwiftyToolz

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
            return isPartOfCycle ? .system(.purple) : .system(.accent)
        }
        else
        {
            return isPartOfCycle ? .system(.red) : .rgba(.gray(brightness: defaultBrightness))
        }
    }
    
    private var isHighlighted: Bool { source.isInFocus || target.isInFocus }
    
    private var isPartOfCycle: Bool
    {
        guard let sourceSCCIndex = source.codeArtifact.metrics.sccIndexTopologicallySorted,
              let targetSCCIndex = target.codeArtifact.metrics.sccIndexTopologicallySorted
        else { return false }
        
        return sourceSCCIndex == targetSCCIndex
    }
    
    @ObservedObject var source: ArtifactViewModel
    @ObservedObject var target: ArtifactViewModel
    @ObservedObject var viewModel: DependencyVM
    
    let defaultBrightness: Double
    let size: Double
}
