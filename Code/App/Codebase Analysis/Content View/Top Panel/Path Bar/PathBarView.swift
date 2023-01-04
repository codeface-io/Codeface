import SwiftUI
import OrderedCollections

struct PathBarView: View
{
    var body: some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 0)
        {
            ForEach(artifactVMStack.indices, id: \.self)
            {
                let artifact = artifactVMStack[$0]
                
                if $0 > 0
                {
                    Image(systemName: "chevron.compact.right")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                        .padding([.leading, .trailing], 3)
                }
                
                Image(systemName: artifact.iconSystemImageName)
                    .foregroundColor(.init(artifact.iconFillColor))
                    .padding(.trailing, 3)
                
                Text(artifact.codeArtifact.name)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: false)
                    .frame(maxHeight: .infinity)
            }
            
            Spacer()
        }
        .padding([.leading, .trailing])
        .frame(height: 28)
    }
    
    @State var artifactVMStack = [ArtifactViewModel]()
}

extension ArtifactViewModel
{
    func getPath() -> [ArtifactViewModel]
    {
        (scope?.getPath() ?? []) + [self]
    }
}
