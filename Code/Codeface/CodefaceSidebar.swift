import SwiftUIToolz
import SwiftUI
import CodefaceCore

struct CodefaceSidebar: View
{
    var body: some View
    {
        if let analysisVM = viewModel.projectAnalysis
        {
            SidebarAnalysisContent(analysisVM: analysisVM)
        }
        else
        {
            Text("Load a code base\nvia the File menu")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
        }
    }
    
    @ObservedObject var viewModel: CodefaceViewModel
}
