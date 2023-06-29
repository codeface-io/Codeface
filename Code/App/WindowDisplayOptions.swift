import Combine

class WindowDisplayOptions: ObservableObject
{
    @Published var showsSubscriptionPanel = false
    @Published var showsLeftSidebar = true
    @Published var showsRightSidebar = false
    @Published var showsLinesOfCode = false
}
