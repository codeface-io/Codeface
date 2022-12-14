import SwiftUI

struct ProofOfConceptView: View {
    
    var body: some View {
        DoubleSidebarView {
            VStack {
                Text("Left sidebar: \(selectedStringLeft ?? "Nothing selected")")
                Text("Right sidebar: \(selectedStringRight ?? "Nothing selected")")
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding()

                    TextField("Search term field",
                              text: $searchTerm,
                              prompt: Text("Type search term"))
                    .padding()
                    .focused($fieldIsFocused)
                }
            }
        } leftSidebar: {
            NavigationStack {
                List(["a", "b", "c"],
                     id: \.self,
                     selection: $selectedStringLeft) {
                    NavigationLink($0, value: $0)
                }
                     .listStyle(.sidebar)
            }
        } rightSidebar: {
            NavigationStack {
                List(["1", "2", "3"],
                     id: \.self,
                     selection: $selectedStringRight) {
                    NavigationLink($0, value: $0)
                }
                     .listStyle(.sidebar)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Button("Focus Field") {
                    fieldIsFocused = true
                }
            }
        }
    }
    
    @FocusState private var fieldIsFocused: Bool
    @State private var searchTerm = ""
    
    @State private var selectedStringLeft: String? = nil
    @State private var selectedStringRight: String? = nil
}

public struct DoubleSidebarView<LeftSidebar: View,
                                    Content: View,
                               RightSidebar: View>: View
{
    public var body: some View
    {
        ZStack
        {
            HStack(spacing: 0)
            {
                leftSidebar()
                    .frame(width: leftSidebarLayout.currentWidth + leftSidebarLayout.dragOffset)
                    .focused($splitViewFocus, equals: .leftSidebar)

                Divider()
                
                content()
                    .frame(minWidth: minimumContentWidth, maxWidth: .infinity)
                    .focused($splitViewFocus, equals: .content)

                Divider()

                rightSidebar()
                    .frame(width: rightSidebarLayout.currentWidth - rightSidebarLayout.dragOffset)
                    .focused($splitViewFocus, equals: .rightSidebar)
            }

            GeometryReader { geo in
                
                DragHandle()
                    .position(x: leftSidebarLayout.currentWidth + 0.5 + leftSidebarLayout.dragOffset,
                              y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged {
                                let potentialLeftWidth = leftSidebarLayout.currentWidth + $0.translation.width
                                let potentialRightPosition = geo.size.width - rightSidebarLayout.widthWhenVisible
                                
                                guard potentialRightPosition - potentialLeftWidth >= minimumContentWidth else { return }
                                
                                leftSidebarLayout.dragOffset = $0.translation.width
                            }
                            .onEnded { _ in withAnimation { leftSidebarLayout.endDragging() } }
                    )

                DragHandle()
                    .position(x: (geo.size.width - (rightSidebarLayout.currentWidth + 0.5)) + rightSidebarLayout.dragOffset,
                              y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged {
                                let potentialLeftWidth = leftSidebarLayout.widthWhenVisible
                                let potentialRightPosition = (geo.size.width - rightSidebarLayout.currentWidth) + $0.translation.width
                                
                                guard potentialRightPosition - potentialLeftWidth >= minimumContentWidth else { return }
                                
                                rightSidebarLayout.dragOffset = $0.translation.width
                            }
                            .onEnded { _ in withAnimation { rightSidebarLayout.endDragging() } }
                    )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(systemImageName: "sidebar.left") {
                    withAnimation { leftSidebarLayout.isVisible.toggle() }
                }
                
                Spacer()
            }

            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()

                Button(systemImageName: "sidebar.right") {
                    withAnimation { rightSidebarLayout.isVisible.toggle() }
                }
            }
        }
    }
    
    // focus
    
    @FocusState private var splitViewFocus: SplitViewFocus?
    enum SplitViewFocus: Int, Hashable { case leftSidebar, content, rightSidebar }
    
    // content
    
    @ViewBuilder public let content: () -> Content
    private let minimumContentWidth = 300.0
    
    // sidebars
    
    @ViewBuilder public let leftSidebar: () -> LeftSidebar
    @State private var leftSidebarLayout = SidebarLayout(side: .left)
    
    @ViewBuilder public let rightSidebar: () -> RightSidebar
    @State private var rightSidebarLayout = SidebarLayout(side: .right)
    
    struct SidebarLayout {
        
        mutating func endDragging() {
            let widthDragDelta = side == .left ? dragOffset : -dragOffset
            
            if currentWidth + widthDragDelta > minimumWidth {
                currentWidth += widthDragDelta
                widthWhenVisible = currentWidth
            } else {
                currentWidth = 0
            }
            
            dragOffset = 0
        }
        
        var isVisible: Bool {
            get { currentWidth == widthWhenVisible }
            
            set {
                if currentWidth == widthWhenVisible {
                    currentWidth = 0
                } else {
                    currentWidth = widthWhenVisible
                }
            }
        }
        
        let side: Side
        enum Side { case left, right }
        
        var widthWhenVisible: Double = 200
        var currentWidth: Double = 200
        var dragOffset: Double = 0
        
        let minimumWidth: Double = 100
    }
}

struct DragHandle: View {
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(maxHeight: .infinity)
            .frame(width: 9)
            .onHover { isHovering in
                if isHovering { NSCursor.resizeLeftRight.push() }
                else { NSCursor.pop() }
            }
    }
}
