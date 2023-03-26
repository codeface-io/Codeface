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
                
                    if let subscription = appStoreClient.fetchedProducts[.subscriptionLevel1]
                    {
                        Text(subscription.displayName + " – " + subscription.description)
                            .opacity(isExpanded ? 0 : 1)
                    }
                    else
                    {
                        ProgressView().progressViewStyle(.linear)
                            .padding(.leading)
                            .opacity(isExpanded ? 0 : 1)
                    }
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
                                VStack(alignment: .leading)
                                {
                                    Text("Loading Subscription Infos ...")
                                    
                                    Center
                                    {
                                        ProgressView().progressViewStyle(.circular)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: 260)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 20)
                        {
                            FeatureView("Support further development",
                                        subtitle: "Fund new features and the open-source infrastructure")
                            
                            FeatureView("Hide this subscription banner",
                                        subtitle: "Gain a bit more space for your code visualizations")
                            
                            FeatureView("Enjoy an early bird advantage",
                                        subtitle: "Get future premium features without price increase")
                            
                            FeatureView("Vote on the next features",
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
