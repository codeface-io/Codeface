import SwiftUI

struct LSPServiceHint: View
{
    var body: some View
    {
        VStack(alignment: .center, spacing: 0)
        {
            HStack
            {
                Spacer()
                
                Button {
                    isBeingPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
                .font(.system(.title))
                .buttonStyle(.borderless)
            }
            .padding(.bottom)
            
            Text("Run LSPService to See More")
                .font(.system(.title))
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            Text("LSPService can provide symbols (like classes and functions) plus all dependencies between them.\nThis enables finer granularity and the visualization of actual architecture.\nLSPService is open source and free.")
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.bottom)
            
            Image("LSPService_Promo_Screenshot")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Link("Download LSPService \(Image(systemName: "chevron.right"))",
                 destination: URL(string: "https://github.com/flowtoolz/LSPService")!)
            .font(.system(.title2))
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 20)
        .padding(60)
        .onTapGesture { isBeingPresented = false }
    }
    
    @Binding var isBeingPresented: Bool
}
