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
                .aspectRatio(contentMode: .fit)
                .frame(height: size)
            
        case .systemImage(let name, let fillColor):
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.init(fillColor))
                .frame(height: size)
        }
    }
    
    let icon: ArtifactIcon
    let size: CGFloat?
}
