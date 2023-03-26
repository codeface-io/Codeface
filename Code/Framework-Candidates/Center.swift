import SwiftUI

struct Center<Content: View>: View
{
    var body: some View
    {
        VStack
        {
            Spacer()
            
            HStack
            {
                Spacer()
                content()
                Spacer()
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder let content: () -> Content
}
