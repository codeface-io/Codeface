import Combine

class DocumentWindowDisplayOptions: ObservableObject
{
    @Published var showsSubscriptionPanel = false
    @Published var showsLeftSidebar: Bool = true
    @Published var showsRightSidebar: Bool = false
    @Published var showsLinesOfCode: Bool = false
}
