import SwiftUI
import SwiftLSP

struct ArtifactIcon: View
{
    var body: some View
    {
        Image(systemName: artifact.iconSystemImageName)
            .foregroundColor(isSelected ? .primary : artifact.iconFillColor)
    }
    
    let artifact: ArtifactViewModel
    let isSelected: Bool
}
