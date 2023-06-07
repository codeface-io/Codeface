import SwiftUI

struct ArtifactIconView: View
{
    init(icon: ArtifactIcon, size: CGFloat? = nil)
    {
        self.icon = icon
        self.size = size
    }
    
    var body: some View
    {
        switch icon
        {
        case .imageName(let imageName):
            Image(imageName)
                .resizable()
                .frame(width: size, height: size)
                .aspectRatio(contentMode: .fit)
            
        case .systemImage(let name, let fillColor):
            Image(systemName: name)
                .foregroundColor(.init(fillColor))
        }
    }
    
    let icon: ArtifactIcon
    let size: CGFloat?
}
