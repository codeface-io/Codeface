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
        
        _rightCurrentWidth = SceneStorage(wrappedValue: viewModel.showsRightSidebar ? Self.rightDefaultWidth : 0,
                                          "rightCurrentWidth")
    }
    
    public var body: some View
    {
        NavigationSplitView(columnVisibility: $columnVisibility)
        {
            leftSidebar()
                .navigationSplitViewColumnWidth(min: Self.minimumWidth,
                                                ideal: 300,
                                                max: 600)
                .listStyle(.sidebar)
                .focused($focus, equals: .leftSidebar)
                .focusable(false)
                
        }
        detail:
        {
            // TODO: rather use HSplitView and get dragging for free?!
            ZStack
            {
                HStack(spacing: 0)
                {
                    content()
                        .frame(minWidth: minimumContentWidth,
                               maxWidth: .infinity)
                        .background(focus == .content ? .green : .clear)
                        .focused($focus, equals: .content)
                        .focusable(false)
                    
                    HStack(spacing: 0)
                    {
                        Divider()
                        
                        rightSidebar()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(minWidth: Self.minimumWidth)
                    .frame(width: rightCurrentWidth - rightDragOffset)
                    .clipShape(Rectangle())
                    .focused($focus, equals: .rightSidebar)
                }
                
                GeometryReader
                {
                    geo in

                    DragHandle()
                        .position(x: (geo.size.width - rightCurrentWidth) + rightDragOffset,
                                  y: geo.size.height / 2)
                        .gesture(
                            DragGesture()
                                .onChanged
                                {
                                    let potentialRightPosition = (geo.size.width - rightCurrentWidth) + $0.translation.width

                                    guard potentialRightPosition >= minimumContentWidth else { return }

                                    rightDragOffset = $0.translation.width
                                }
                                .onEnded { _ in endDraggingRight() }
                        )
                }
            }
        }
        .toolbar
        {
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
            showsLeftSidebar in
            
            withAnimation
            {
                columnVisibility = showsLeftSidebar ? .doubleColumn : .detailOnly
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
        .onChange(of: focus)
        {
            [focus] newFocus in

            let contentOrRightLostFocus = newFocus == nil && focus != .leftSidebar
            if contentOrRightLostFocus { self.focus = .leftSidebar }
        }
    }
    
    // MARK: - Focus
    
    @FocusState private var focus: Focus?
    private enum Focus: String, Hashable { case leftSidebar, content, rightSidebar }
    
    // MARK: - Content
    
    @ViewBuilder public let content: () -> Content
    private let minimumContentWidth = 300.0
    
    // MARK: - Left Sidebar

    @ViewBuilder public let leftSidebar: () -> LeftSidebar
    
    @State var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
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
    static var minimumWidth: Double { 200 }
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
