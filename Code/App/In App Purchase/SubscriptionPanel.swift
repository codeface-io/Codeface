import StoreKit
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
                if !appStoreClient.ownsProducts
                {
                    Image(systemName: "cup.and.saucer")
                        .imageScale(.large)
                        .padding(.leading)
                        .opacity(isExpanded ? 0 : 1)
                
                    Text("Sponsor the Development of This App")
                        .opacity(isExpanded ? 0 : 1)
                }
                
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
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0.05 * geo.size.height)
                    {
                        VStack(alignment: .leading, spacing: 0)
                        {
                            if let subscription = appStoreClient.fetchedProducts[.subscriptionLevel1]
                            {
                                SubscriptionManagementView(subscription: subscription)
                            }
                            else
                            {
                                VStack
                                {
                                    Spacer()
                                    
                                    HStack
                                    {
                                        Spacer()
                                        ProgressView().progressViewStyle(.circular)
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: 260)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 20)
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
            .padding([.leading, .trailing], 30)
            .frame(height: isExpanded ? nil : 0)
            .clipped()
        }
        .frame(height: height)
        .background(Color(NSColor.controlBackgroundColor))
        .clipped()
        .onAppear
        {
            Task
            {
                do
                {
                    try await AppStoreClient.shared.fetch(product: .subscriptionLevel1)
                }
                catch
                {
                    log(error: error.localizedDescription)
                }
            }
        }
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

struct SubscriptionManagementView: View
{
    var body: some View
    {
        let userIsSubscribed = appStoreClient.owns(subscription)
        
        Text(subscription.displayName)
            .font(.title)
            .fontWeight(.bold)
            .padding(.bottom, 6)
        
        Text(subscription.description)
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.bottom)
        
        let green = Color(.systemGreen)
        
        if userIsSubscribed
        {
            HStack
            {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(green)
                
                Text("Subscribed")
            }
            .font(.title3)
            .fontWeight(.medium)
        }
        else
        {
            Text(subscription.displayPrice + " / month")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(green)
        }
        
        Spacer()
        
        if userIsSubscribed
        {
            AsyncButton("Vote on Next Features", colorScheme: .green)
            {
                openURL(URL(string: FeatureVote.urlString)!)
            }
        }
        else
        {
            AsyncButton("Subscribe", colorScheme: .accent)
            {
                do
                {
                    try await appStoreClient.purchase(subscription)
                }
                catch
                {
                    log(error: error.localizedDescription)
                }
            }
        }
    }
    
    let subscription: Product
    @ObservedObject private var appStoreClient = AppStoreClient.shared
    @Environment(\.openURL) var openURL
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
                .foregroundColor(Color(.systemGreen))
        }
    }
    
    let title: String
    let subtitle: String
}

struct AsyncButton: View
{
    internal init(_ title: String,
                  colorScheme: ColorScheme = .gray,
                  action: @escaping () async -> Void)
    {
        self.title = title
        self.colorScheme = colorScheme
        self.action = action
    }
    
    var body: some View
    {
        ZStack(alignment: .center)
        {
            Text(title)
                .foregroundColor(.white)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(14.5)
                .opacity(isWaitingForCompletion ? 0 : 1)

            ProgressView().progressViewStyle(.circular)
                .foregroundColor(.white)
                .opacity(isWaitingForCompletion ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
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
        switch colorScheme
        {
        case .accent: return .accentColor
        case .gray: return .init(white: 0.5).opacity(0.75)
        case .green: return Color(.systemGreen)
        }
    }
    
    let title: String
    
    let colorScheme: ColorScheme
    
    enum ColorScheme
    {
        case accent, gray, green
    }
    
    let action: () async -> Void
    
    @State private var isWaitingForCompletion = false
    
    private static let cornerRadius: CGFloat = 14
}
