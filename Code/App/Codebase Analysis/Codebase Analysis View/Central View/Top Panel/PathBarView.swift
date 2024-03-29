import SwiftUI

struct PathBarView: View
{
    var body: some View
    {
        HStack(alignment: .firstTextBaseline, spacing: 0)
        {
            ForEach(overviewBar.artifactVMStack.indices, id: \.self)
            {
                let vm = overviewBar.artifactVMStack[$0]
                
                if $0 > 0
                {
                    Image(systemName: "chevron.compact.right")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                        .padding([.leading, .trailing], 3)
                }
                
                Image(systemName: vm.iconSystemImageName)
                    .foregroundColor(.init(vm.iconFillColor))
                    .padding(.trailing, 3)
                
                Text(vm.codeArtifact.name)
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
