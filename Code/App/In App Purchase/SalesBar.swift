import SwiftUI

struct SalesBar: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            Divider()
            
            HStack(alignment: .firstTextBaseline)
            {
                Image(systemName: "cup.and.saucer")
                    .imageScale(.large)
                    .padding(.leading)
                
                Text("Sponsor the Development of This App")
                
                Spacer()
                
                ZStack
                {
                    Image(systemName: "xmark")
                        .opacity(isExpanded ? 1 : 0)
                    
                    Image(systemName: "chevron.up")
                        .opacity(isExpanded ? 0 : 1)
                }
                .imageScale(.large)
                .padding([.top, .bottom], 12)
                .padding([.leading, .trailing])
                .contentShape(Rectangle())
                .onTapGesture
                {
                    withAnimation
                    {
                        isExpanded.toggle()
                    }
                }
            }
            .font(.system(.title2, weight: .light))
            
            VStack(spacing: 0)
            {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, -10)
                
                Button("Sponsor the Developer With 2$ a Month")
                {
                    AppStoreClient.shared.purchaseSubscriptionLevel1()
                }
                .padding(.bottom)
                .buttonStyle(.borderedProminent)
                .opacity(isExpanded ? 1 : 0)
                
                Button("Restore my Ongoing Sponsorship")
                {
                    AppStoreClient.shared.forceRestorePurchasedProducts()
                }
                .padding(.bottom, 42)
                .opacity(isExpanded ? 1 : 0)
            }
            .frame(height: isExpanded ? nil : 0)
            .clipped()
        }
        .frame(height: isExpanded ? 350 : nil)
        .background(Color(NSColor.controlBackgroundColor))
        .onTapGesture
        {
            if !isExpanded
            {
                withAnimation
                {
                    isExpanded.toggle()
                }
            }
        }
    }
    
    @State var isExpanded = false
}
