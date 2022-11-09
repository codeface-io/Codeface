import SwiftUIToolz
import SwiftUI
import SwiftLSP
import CodefaceCore

struct ArtifactIcon: View
{
    var body: some View
    {
        Image(systemName: artifact.iconSystemImageName)
            .foregroundColor(isSelected ? .primary : .init(artifact.iconFillColor))
    }
    
    let artifact: ArtifactViewModel
    let isSelected: Bool
}
