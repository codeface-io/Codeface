import SwiftUI

struct LoadingProgressView: View
{
    var body: some View
    {
        VStack
        {
            ProgressView()
                .progressViewStyle(.circular)
                .padding(.bottom)
            
            Text(primaryText)
                .padding(.bottom, 1)
            
            Text(secondaryText)
                .foregroundColor(.secondary)
        }
        .multilineTextAlignment(.center)
    }
    
    let primaryText: String
    let secondaryText: String
}
