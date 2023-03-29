import SwiftUI

struct Center<Content: View>: View
{
    var body: some View
    {
        HStack
        {
            Spacer()
            
            VStack
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
