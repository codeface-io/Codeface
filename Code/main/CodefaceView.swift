import SwiftUI
import SwiftObserver

class CodefaceView: NSHostingView<ContentView>
{
    init() { super.init(rootView: ContentView()) }
    
    required init(rootView: ContentView) { super.init(rootView: rootView) }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) { nil }
}

struct Preview: PreviewProvider
{
    static var previews: some View
    {
        ContentView().previewDisplayName("ContentView")
    }
}

struct ContentView: View
{
    var body: some View
    {
        NavigationView
        {
            List(model.folders, id: \.path, children: \.subfolders)
            {
                item in Text(item.name)
            }
            .listStyle(SidebarListStyle())
            
            Text("Huhu")
        }
    }
    
    @ObservedObject private var model = Model()
    
    private class Model: ObservableObject, Observer
    {
        init()
        {
            observe(Project.messenger)
            {
                switch $0
                {
                case .didSetActiveProject(let activeProject):
                    if let activeProject = activeProject
                    {
                        self.folders = [activeProject.rootFolder]
                    }
                    else
                    {
                        self.folders = []
                    }
                }
            }
        }
        
        @Published var folders = [CodeFolder]()
        
        let receiver = Receiver()
    }
}
