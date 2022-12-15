import SwiftUI
import CodefaceCore

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
            }
            
            Spacer()
        }
        .padding(.leading)
        .frame(height: 29)
    }
    
    @ObservedObject var overviewBar: PathBar
}
