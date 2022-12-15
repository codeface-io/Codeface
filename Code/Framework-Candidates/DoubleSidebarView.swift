import SwiftUI

public struct DoubleSidebarView<LeftSidebar: View, Content: View, RightSidebar: View>: View
{
    init(viewModel: DoubleSidebarViewModel,
         content: @escaping () -> Content,
         leftSidebar: @escaping () -> LeftSidebar,
         rightSidebar: @escaping () -> RightSidebar)
    {
        self.viewModel = viewModel
        self.content = content
        self.leftSidebar = leftSidebar
        self.rightSidebar = rightSidebar
        
        let leftWidth = viewModel.showsLeftSidebar ? SidebarLayout.leftDefaultWidth : 0
        _leftSidebarLayout = State(wrappedValue: SidebarLayout(side: .left, currentWidth: leftWidth))
        
        let rightWidth = viewModel.showsRightSidebar ? SidebarLayout.rightDefaultWidth : 0
        _rightSidebarLayout = State(wrappedValue: SidebarLayout(side: .right, currentWidth: rightWidth))
    }
    
    public var body: some View
    {
        ZStack
        {
            HStack(spacing: 0)
            {
                HStack(spacing: 0)
                {
                    leftSidebar()
                    Divider()
                }
                .listStyle(.sidebar)
                .frame(width: leftSidebarLayout.currentWidth + leftSidebarLayout.dragOffset)
                .focused($focus, equals: .leftSidebar)

                content()
                    .frame(minWidth: minimumContentWidth, maxWidth: .infinity)
                    .focused($focus, equals: .content)

                HStack(spacing: 0)
                {
                    Divider()
                    rightSidebar()
                }
                .listStyle(.sidebar)
                .frame(width: rightSidebarLayout.currentWidth - rightSidebarLayout.dragOffset)
                .focused($focus, equals: .rightSidebar)
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
                    withAnimation {
                        leftSidebarLayout.isVisible.toggle()
                        viewModel.showsLeftSidebar = leftSidebarLayout.isVisible
                    }
                }
                .help("Toggle Navigator (⌘0)")
                
                Spacer()
            }

            ToolbarItemGroup(placement: .primaryAction) {
                Spacer()

                Button(systemImageName: "sidebar.right") {
                    withAnimation {
                        rightSidebarLayout.isVisible.toggle()
                        viewModel.showsRightSidebar = rightSidebarLayout.isVisible
                    }
                }
                .help("Toggle Inspector (⌥⌘0)")
            }
        }
        .onChange(of: viewModel.showsLeftSidebar) { showLeftSidebar in
            guard showLeftSidebar != leftSidebarLayout.isVisible else { return }
            withAnimation { leftSidebarLayout.isVisible = showLeftSidebar }
        }
        .onChange(of: viewModel.showsRightSidebar) { showRightSidebar in
            guard showRightSidebar != rightSidebarLayout.isVisible else { return }
            withAnimation { rightSidebarLayout.isVisible = showRightSidebar }
        }
        .onAppear {
            focus = .leftSidebar
        }
    }
    
    @ObservedObject var viewModel: DoubleSidebarViewModel
    
    // focus
    
    @FocusState private var focus: Focus?
    private enum Focus: Int, Hashable { case leftSidebar, content, rightSidebar }
    
    // content
    
    @ViewBuilder public let content: () -> Content
    private let minimumContentWidth = 300.0
    
    // sidebars
    
    @ViewBuilder public let leftSidebar: () -> LeftSidebar
    @State private var leftSidebarLayout: SidebarLayout
    
    @ViewBuilder public let rightSidebar: () -> RightSidebar
    @State private var rightSidebarLayout: SidebarLayout
    
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
        
        var widthWhenVisible: Double = rightDefaultWidth
        var currentWidth: Double = rightDefaultWidth
        var dragOffset: Double = 0
        
        let minimumWidth: Double = 100
        
        static var leftDefaultWidth: Double { 300 }
        static var rightDefaultWidth: Double { 250 }
    }
}

class DoubleSidebarViewModel: ObservableObject
{
    @Published var showsLeftSidebar: Bool = true
    @Published var showsRightSidebar: Bool = false
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
