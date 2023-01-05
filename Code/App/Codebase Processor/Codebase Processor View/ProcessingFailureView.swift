import SwiftUI

struct ProcessingFailureView: View
{
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("An error occured while loading the codebase:")
                .foregroundColor(Color(NSColor.systemRed))
                .padding(.bottom)

            Text(errorMessage)
        }
    }
    
    let errorMessage: String
}
