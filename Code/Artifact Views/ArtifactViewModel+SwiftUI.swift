import SwiftUI
import CodefaceCore

extension ArtifactViewModel {
    var fontDesign: Font.Design {
        if case .file = kind { return .monospaced }
        return .default
    }
}
