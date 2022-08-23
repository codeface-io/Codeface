import SwiftUI

extension ArtifactViewModel {
    var fontDesign: Font.Design {
        if case .file = kind { return .monospaced }
        return .default
    }
}
