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
                
                    if let bannerText
                    {
                        Text(bannerText)
                            .lineLimit(1)
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
                AppIcon()
                
                GeometryReader
                {
                    geo in
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0.05 * geo.size.height)
                    {
                        VStack(alignment: .leading, spacing: 0)
                        {
                            if let subscriptionFetch
                            {
                                switch subscriptionFetch
                                {
                                case .success(let subscription):
                                    SubscriptionManagementView(subscription: subscription)
                                
                                case .failure(let error):
                                    Label
                                    {
                                        Text("Couldn't load infos from App Store:")
                                    }
                                    icon:
                                    {
                                        Image(systemName: "xmark.octagon.fill")
                                            .foregroundColor(Color(.systemRed))
                                    }
                                    .padding(.bottom)
                                    
                                    Text(error.localizedDescription)
                                        .padding(.bottom)
                                    
                                    Button {
                                        Task { await retrieveSubscription() }
                                    } label: {
                                        Label("Retry", systemImage: "arrow.clockwise")
                                    }
                                }
                            }
                            else
                            {
                                Label
                                {
                                    Text("Loading Subscription Infos ...")
                                }
                                icon:
                                {
                                    Image(systemName: "icloud.and.arrow.down")
                                        .foregroundColor(.primary)
                                }
                                
                                Center
                                {
                                    ProgressView().progressViewStyle(.circular)
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
        .background(Color(.controlBackgroundColor))
        .clipped()
        .task
        {
            await retrieveSubscription()
        }
    }
    
    private func retrieveSubscription() async
    {
        subscriptionFetch = nil
        
        do
        {
            let subscriptionProduct = try await appStoreClient.retrieveProduct(for: .subscriptionLevel1)
            
            subscriptionFetch = .success(subscriptionProduct)
        }
        catch
        {
            log(error: "Couldn't get product infos from App Store because of this error:\n\t" + error.localizedDescription)
            
            subscriptionFetch = .failure(error)
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
    
    private var bannerText: String?
    {
        guard let subscriptionFetch else { return nil }
        
        if case .success(let subscription) = subscriptionFetch
        {
            return subscription.displayName + " – " + subscription.description
        }
        else
        {
            // when the fetch failed, we display a default text on the banner instead of error indication
            return "Support the Development of Codeface"
        }
    }
    
    @State private var subscriptionFetch: Result<Product, Error>? = nil
    @ObservedObject private var appStoreClient = AppStoreClient.shared
}
