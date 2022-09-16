import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct CodefaceSidebar: View
{
    var body: some View
    {
        if let processorVM = viewModel.projectProcessorVM
        {
            SidebarAnalysisContent(processorVM: processorVM)
        }
        else
        {
            Text("To load a codebase,\nsee the File menu.")
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    @ObservedObject var viewModel: Codeface
}
