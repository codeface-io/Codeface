import SwiftUI
import SwiftyToolz

struct SubscriptionPanel: View
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
                    .opacity(isExpanded ? 0 : 1)
                
                Text("Sponsor the Development of This App")
                    .opacity(isExpanded ? 0 : 1)
                
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
            }
            .font(.system(.title2, weight: .light))
            .contentShape(Rectangle())
            .onTapGesture
            {
                withAnimation
                {
                    toggle()
                }
            }
            
            HStack(spacing: 0)
            {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                GeometryReader
                {
                    geo in
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0.10 * geo.size.height)
                    {
                        VStack(alignment: .leading, spacing: 0)
                        {
                            Text("Codeface Sponsorship")
                                .font(.title)
                                .padding(.bottom, 6)
                            
                            Text("Become a supporter of this app with 2€ per month")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if appStoreClient.ownsProducts
                            {
                                Label {
                                    Text("Subscribed")
                                } icon: {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                                .padding(.bottom)
                                
                                AsyncButton("Request Refund")
                                {
                                    await AppStoreClient.shared.refundSubscriptionLevel1()
                                }
                            }
                            else
                            {
                                AsyncButton("Subscribe", isProminent: true)
                                {
                                    await AppStoreClient.shared.purchaseSubscriptionLevel1()
                                }
                                .padding(.bottom)
                                
                                AsyncButton("Restore My Subscription")
                                {
                                    await AppStoreClient.shared.forceRestorePurchasedProducts()
                                }
                            }
                        }
                        
                        VStack(spacing: 20)
                        {
                            BulletPoint("Support further development",
                                        subtitle: "Fund new features and the open-source infrastructure")
                            
                            BulletPoint("Hide this subscription banner",
                                        subtitle: "Gain a bit more space for your code visualizations")
                            
                            BulletPoint("Enjoy an early bird advantage",
                                        subtitle: "Get future premium features without price increase")
                            
                            BulletPoint("Vote on the next features",
                                        subtitle: "Shape Codeface with your ideas and by ranking ours")
                        }
                    }
                    .fixedSize(horizontal: false, vertical: false)
                    .padding([.top, .bottom, .trailing], 0.10 * geo.size.height)
                    .opacity(isExpanded ? 1 : 0)
                }
            }
            .padding(.bottom, 50)
            .frame(height: isExpanded ? nil : 0)
            .clipped()
        }
        .frame(height: height)
        .background(Color(NSColor.controlBackgroundColor))
        .clipped()
    }
    
    private var height: CGFloat?
    {
        switch visibility
        {
        case .full: return 350
        case .banner: return nil
        case .hidden: return 0
        }
    }
    
    private var visibility: Visibility
    {
        isExpanded ? .full : collapsedVisibility
    }
    
    private func toggle()
    {
        isExpanded.toggle()
    }
    
    @Binding var isExpanded: Bool
    
    let collapsedVisibility: Visibility
    
    enum Visibility
    {
        case full, banner, hidden
    }

    @ObservedObject private var appStoreClient = AppStoreClient.shared
}

struct BulletPoint: View
{
    init(_ title: String, subtitle: String)
    {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View
    {
        HStack
        {
            Label
            {
                VStack(alignment: .leading, spacing: 3)
                {
                    Text(title)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .foregroundColor(.secondary)
                }
            } icon: {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
    }
    
    let title: String
    let subtitle: String
}

struct AsyncButton: View
{
    internal init(_ title: String,
                  isProminent: Bool = false,
                  action: @escaping () async -> Void)
    {
        self.title = title
        self.isProminent = isProminent
        self.action = action
    }
    
    var body: some View
    {
        ZStack(alignment: .center)
        {
            Text(title)
                .fontWeight(.semibold)
                .padding(14.5)
                .opacity(isWaitingForCompletion ? 0 : 1)

            ProgressView().progressViewStyle(.circular)
                .opacity(isWaitingForCompletion ? 1 : 0)
        }
        .frame(maxWidth: 310)
        .background(RoundedRectangle(cornerRadius: Self.cornerRadius).fill(color))
        .contentShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
        .onTapGesture
        {
            Task
            {
                isWaitingForCompletion = true
                await action()
                isWaitingForCompletion = false
            }
        }
    }
    
    private var color: SwiftUI.Color
    {
        isProminent ? .accentColor : .secondary.opacity(0.5)
    }
    
    let title: String
    let isProminent: Bool
    let action: () async -> Void
    
    @State private var isWaitingForCompletion = false
    
    private static let cornerRadius: CGFloat = 14
}
