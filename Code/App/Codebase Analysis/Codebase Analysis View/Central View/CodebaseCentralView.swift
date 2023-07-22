import SwiftUI

struct CodebaseCentralView: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            TopBar(analysis: analysis)
            
            // AnalysisContentView has the selectedArtifact explicitly and can thereby directly observe the properties on analysis.selectedArtifact
            CodebaseContentView(analysis: analysis,
                                selectedArtifact: analysis.selectedArtifact)
            
            if GlobalSettings.shared.showPurchasePanel
            {
                PurchasePanelView(isExpanded: $displayOptions.showsSubscriptionPanel,
                                  collapsedVisibility: appStoreClient.ownsProducts ? .hidden : .banner)
            }
        }
        .animation(.default, value: displayOptions.showsSubscriptionPanel)
    }
    
    @ObservedObject var analysis: CodebaseAnalysis
    @ObservedObject var appStoreClient = AppStoreClient.shared
    @ObservedObject var displayOptions: WindowDisplayOptions
}
