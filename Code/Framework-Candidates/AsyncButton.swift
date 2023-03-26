import SwiftUI

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
