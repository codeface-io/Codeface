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
                .frame(width: imageSize, height: imageSize)
                .aspectRatio(contentMode: .fit)
                .padding(padding)
            
        case .systemImage(let name, let fillColor):
            Image(systemName: name)
                .foregroundColor(.init(fillColor))
        }
    }
    
    private var imageSize: CGFloat? {
        guard let size else { return nil }
        return size - (2 * padding)
    }
    
    private var padding: CGFloat { (size ?? 0) * 0.05 }
    
    let icon: ArtifactIcon
    let size: CGFloat?
}
