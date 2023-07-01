import SwiftUI

struct PathBarView: View
{
    var body: some View
    {
        HStack(alignment: .center, spacing: 0)
        {
            ForEach(overviewBar.artifactVMStack.indices, id: \.self)
            {
                let artifactVM = overviewBar.artifactVMStack[$0]
                
                if $0 > 0
                {
                    Image(systemName: "chevron.compact.right")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                        .padding([.leading, .trailing], 3)
                }
                
                ArtifactIconView(icon: artifactVM.icon, size: 14)
                    .padding(.trailing, 3)
                
                Text(artifactVM.displayName)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: false)
                    .frame(maxHeight: .infinity)
            }
            
            Spacer()
        }
        .padding([.leading, .trailing])
        .frame(height: 28)
    }
    
    @ObservedObject var overviewBar: PathBar
}

extension ArtifactViewModel
{
    func getPath() -> [ArtifactViewModel]
    {
        (scope?.getPath() ?? []) + [self]
    }
}
