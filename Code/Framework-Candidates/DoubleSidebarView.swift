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
        
        _leftCurrentWidth = SceneStorage(wrappedValue: viewModel.showsLeftSidebar ? Self.leftDefaultWidth : 0,
                                         "leftCurrentWidth")
        
        _rightCurrentWidth = SceneStorage(wrappedValue: viewModel.showsRightSidebar ? Self.rightDefaultWidth : 0,
                                          "rightCurrentWidth")
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
                .frame(width: leftCurrentWidth + leftDragOffset)
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
                .frame(width: rightCurrentWidth - rightDragOffset)
                .focused($focus, equals: .rightSidebar)
            }

            GeometryReader
            {
                geo in
                
                DragHandle()
                    .position(x: leftCurrentWidth + 0.5 + leftDragOffset,
                              y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged
                            {
                                let potentialLeftWidth = leftCurrentWidth + $0.translation.width
                                let potentialRightPosition = geo.size.width - rightWidthWhenVisible
                                
                                guard potentialRightPosition - potentialLeftWidth >= minimumContentWidth else { return }
                                
                                leftDragOffset = $0.translation.width
                            }
                            .onEnded { _ in endDraggingLeft() }
                    )

                DragHandle()
                    .position(x: (geo.size.width - (rightCurrentWidth + 0.5)) + rightDragOffset,
                              y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged
                            {
                                let potentialLeftWidth = leftWidthWhenVisible
                                let potentialRightPosition = (geo.size.width - rightCurrentWidth) + $0.translation.width
                                
                                guard potentialRightPosition - potentialLeftWidth >= minimumContentWidth else { return }
                                
                                rightDragOffset = $0.translation.width
                            }
                            .onEnded { _ in endDraggingRight() }
                    )
            }
        }
        .toolbar
        {
            ToolbarItemGroup(placement: .navigation)
            {
                Button(systemImageName: "sidebar.left")
                {
                    withAnimation
                    {
                        toggleLeft()
                        viewModel.showsLeftSidebar = leftIsVisible
                    }
                }
                .help("Toggle Navigator (⌘0)")
                
                Spacer()
            }

            ToolbarItemGroup(placement: .primaryAction)
            {
                Spacer()

                Button(systemImageName: "sidebar.right")
                {
                    withAnimation
                    {
                        toggleRight()
                        viewModel.showsRightSidebar = rightIsVisible
                    }
                }
                .help("Toggle Inspector (⌥⌘0)")
            }
        }
        .onChange(of: viewModel.showsLeftSidebar)
        {
            showLeftSidebar in
            
            if showLeftSidebar != leftIsVisible
            {
                withAnimation { set(leftIsVisible: showLeftSidebar) }
            }
        }
        .onChange(of: viewModel.showsRightSidebar)
        {
            showsRightSidebar in
            
            if showsRightSidebar != rightIsVisible
            {
                withAnimation { set(rightIsVisible: showsRightSidebar) }
            }
        }
        .onAppear
        {
            focus = .leftSidebar
        }
    }
    
    // MARK: - Focus
    
    @FocusState private var focus: Focus?
    private enum Focus: Int, Hashable { case leftSidebar, content, rightSidebar }
    
    // MARK: - Content
    
    @ViewBuilder public let content: () -> Content
    private let minimumContentWidth = 300.0
    
    // MARK: - Left Sidebar
    
    @ViewBuilder public let leftSidebar: () -> LeftSidebar
        
    func endDraggingLeft()
    {
        if leftCurrentWidth + leftDragOffset > Self.minimumWidth
        {
            leftCurrentWidth += leftDragOffset
            leftWidthWhenVisible = leftCurrentWidth
            leftDragOffset = 0
        }
        else
        {
            withAnimation
            {
                leftCurrentWidth = 0
                leftDragOffset = 0
            }
        }
    }

    func toggleLeft() { set(leftIsVisible: !leftIsVisible) }
    
    func set(leftIsVisible newValue: Bool)
    {
        leftCurrentWidth = newValue ? leftWidthWhenVisible : 0
    }
    
    var leftIsVisible: Bool { leftCurrentWidth >= Self.minimumWidth }
    
    @SceneStorage("leftWidthWhenVisible") var leftWidthWhenVisible = leftDefaultWidth
    @SceneStorage var leftCurrentWidth: Double
    @State var leftDragOffset: Double = 0
    static var leftDefaultWidth : Double { 300 }
    
    // MARK: - Right Sidebar
    
    @ViewBuilder public let rightSidebar: () -> RightSidebar
        
    func endDraggingRight()
    {
        if rightCurrentWidth - rightDragOffset > Self.minimumWidth
        {
            rightCurrentWidth -= rightDragOffset
            rightWidthWhenVisible = rightCurrentWidth
            rightDragOffset = 0
        }
        else
        {
            withAnimation
            {
                rightCurrentWidth = 0
                rightDragOffset = 0
            }
        }
    }
    
    func toggleRight() { set(rightIsVisible: !rightIsVisible) }
    
    func set(rightIsVisible newValue: Bool)
    {
        rightCurrentWidth = newValue ? rightWidthWhenVisible : 0
    }
    
    var rightIsVisible: Bool { rightCurrentWidth >= Self.minimumWidth }
        
    @SceneStorage("rightWidthWhenVisible") var rightWidthWhenVisible = rightDefaultWidth
    @SceneStorage var rightCurrentWidth: Double
    @State var rightDragOffset: Double = 0
    static var rightDefaultWidth : Double { 250 }
    
    // MARK: - General
    
    @ObservedObject var viewModel: DoubleSidebarViewModel
    static var minimumWidth: Double { 100 }
}

class DoubleSidebarViewModel: ObservableObject
{
    @Published var showsLeftSidebar: Bool = true
    @Published var showsRightSidebar: Bool = false
}

struct DragHandle: View
{
    var body: some View
    {
        Rectangle()
            .fill(.clear)
            .frame(maxHeight: .infinity)
            .frame(width: 9)
            .onHover
            {
                if $0 { NSCursor.resizeLeftRight.push() }
                else { NSCursor.pop() }
            }
    }
}
