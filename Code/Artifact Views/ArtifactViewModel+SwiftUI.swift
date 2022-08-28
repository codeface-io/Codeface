import SwiftUI
import CodefaceCore

extension ArtifactViewModel
{
    var fontDesign: Font.Design
    {
        if case .symbol = kind { return .monospaced }
        return .default
    }
}
