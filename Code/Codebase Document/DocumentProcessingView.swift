import SwiftUIToolzOLD
import SwiftUI
import SwiftLSP
import SwiftyToolz
import CodefaceCore

struct DocumentProcessingView: View
{
    var body: some View
    {
        switch processorVM.processorState
        {
        case .didLocateCodebase:
            LoadingProgressView(primaryText: "Project Located",
                                secondaryText: "✅").padding()
            
        case .retrievingCodebase(let step):
            LoadingProgressView(primaryText: "Loading " + processorVM.codebaseDisplayName,
                                secondaryText: step.rawValue).padding()
            
        case .didRetrieveCodebase:
            LoadingProgressView(primaryText: "Project Data Complete",
                                secondaryText: "✅").padding()
            
        case .visualizingCodebaseArchitecture(let step):
            LoadingProgressView(primaryText: "Analyzing " + processorVM.codebaseDisplayName,
                                secondaryText: step.rawValue).padding()
            
        case .didVisualizeCodebaseArchitecture(_, let rootArtifact):
            CodebaseAnalysisView(sidebarViewModel: sidebarViewModel,
                                 rootArtifact: rootArtifact,
                                 codefaceDocument: codefaceDocument,
                                 processorVM: processorVM)
            
        case .failed(let errorMessage):
            VStack(alignment: .leading)
            {
                Text("An error occured while loading the codebase:")
                    .foregroundColor(Color(NSColor.systemRed))
                    .padding(.bottom)
                
                Text(errorMessage)
            }
            .padding()
        }
    }
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
    
    let sidebarViewModel: DoubleSidebarViewModel
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
    
    @FocusState private var listIsInFocus
}

struct CodebaseAnalysisView: View
{    
    var body: some View
    {
        DoubleSidebarView(viewModel: sidebarViewModel)
        {
            Group
            {
                if let artifactVM = codefaceDocument.selectedArtifact
                {
                    CodebaseAnalysisContentView(artifactVM: artifactVM,
                                                codefaceDocument: codefaceDocument,
                                                processorVM: processorVM)
                }
                else
                {
                    Text("Select a code artifact in the navigator on the left.")
                }
            }
        }
        leftSidebar:
        {
            NavigationStack
            {
                List([rootArtifact],
                     children: \.children,
                     selection: $codefaceDocument.selectedArtifact)
                {
                    artifactVM in

                    NavigationLink(value: artifactVM)
                    {
                        SidebarLabel(artifact: artifactVM,
                                     isSelected: artifactVM == codefaceDocument.selectedArtifact)
                    }
                }
            }
            .onAppear
            {
                Task { codefaceDocument.selectedArtifact = rootArtifact }
            }
        }
        rightSidebar:
        {
            Group
            {
                if let artifactVM = codefaceDocument.selectedArtifact
                {
                    ArtifactInspectorView(artifactVM: artifactVM)
                }
                else
                {
                    Text("Select a code artifact in the Navigator.")
                }
            }
        }
    }
    
    let sidebarViewModel: DoubleSidebarViewModel
    let rootArtifact: ArtifactViewModel
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}

struct CodebaseAnalysisContentView: View {
    
    var body: some View {
    
        VStack(spacing: 0) {
        
            Group {
                PathBarView(overviewBar: processorVM.pathBar)
                
                HStack(alignment: .firstTextBaseline) {
                    SearchField(processorVM: processorVM)
                        .padding(.top, 1)
                        .padding([.bottom, .trailing], 6)
                        .padding([.leading])
                    
                    Button("Done")
                    {
                        withAnimation(.easeInOut(duration: SearchVM.visibilityToggleAnimationDuration))
                        {
                            processorVM.searchVM.searchBarIsShown = false
                        }
                    }
                    .focusable(false)
                    .padding(.trailing)
                }
                .frame(height: processorVM.searchVM.searchBarIsShown ? nil : 0)
                .focusable(processorVM.searchVM.searchBarIsShown)
                .clipShape(Rectangle())
            }
            .background(Color(NSColor.controlBackgroundColor))
            
            if artifactVM.filteredParts.isEmpty
            {
                let contentIsFilteredOut = !artifactVM.passesSearchFilter || !artifactVM.parts.isEmpty
                
                if contentIsFilteredOut
                {
                    VStack(alignment: .center)
                    {
                        Spacer()
                        
                        Label("No Search Results", systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.system(.title))
                            .padding(.bottom)
                        
                        Text(artifactVM.codeArtifact.name + " does not contain the search term")
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Button("Remove Search Filter", role: .destructive)
                        {
                            processorVM.clearSearchField()
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                else if case .symbol = artifactVM.kind
                {
                    CodeView(artifact: artifactVM)
                }
                else
                {
                    VStack
                    {
                        Label("Empty " + artifactVM.codeArtifact.kindName, systemImage: "xmark.rectangle")
                            .foregroundColor(.secondary)
                            .font(.system(.title))
                            .padding(.bottom)
                        
                        if serverManager.serverIsWorking
                        {
                            Text(artifactVM.codeArtifact.name + " contains no further symbols.")
                                .foregroundColor(.secondary)
                        }
                        else
                        {
                            LSPServiceHint()
                        }
                    }
                    .padding(50)
                }
            }
            else
            {
                HStack(spacing: 0)
                {
                    switch processorVM.displayMode
                    {
                    case .treeMap: TreeMap(rootArtifactVM: artifactVM,
                                           viewModel: processorVM)
                    case .code: CodeView(artifact: artifactVM)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar
                {
                    ToolbarItemGroup(placement: ToolbarItemPlacement.secondaryAction)
                    {
                        Button {
                            withAnimation(.easeInOut(duration: SearchVM.visibilityToggleAnimationDuration)) {
                                processorVM.searchVM.searchBarIsShown.toggle()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .help("Toggle the search bar")
                        
                        DisplayModePicker(displayMode: $processorVM.displayMode)
                    }
                }
            }
        }
    }
    
    let artifactVM: ArtifactViewModel
    
    @ObservedObject var codefaceDocument: CodefaceDocument
    @ObservedObject var processorVM: ProjectProcessorViewModel
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}

struct ArtifactInspectorView: View
{
    var body: some View
    {
        List
        {
            Label
            {
                Text(artifactVM.codeArtifact.name)
            }
            icon:
            {
                ArtifactIcon(artifact: artifactVM, isSelected: false)
            }
            .font(.title3)
            
            Text(artifactVM.codeArtifact.kindName)
                .foregroundColor(.secondary)
                .font(.title3)
            
            Divider()
            
            HStack {
                Label("Lines of code:",
                      systemImage: "text.alignleft")
                Spacer()
                Text("\(artifactVM.codeArtifact.linesOfCode)")
                    .foregroundColor(.init(artifactVM.linesOfCodeColor))
            }
            .font(.title3)
            
            Divider()
            
            HStack {
                Label("Is itself in cycles:",
                      systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                Spacer()
                
                let isInCycle = artifactVM.codeArtifact.metrics.isInACycle ?? false
                
                let cycleColor: SwiftyToolz.Color = isInCycle ? .rgb(1, 0, 0) : .rgb(0, 1, 0)
                
                Text("\(isInCycle ? "Yes" : "No")")
                    .foregroundColor(SwiftUI.Color(cycleColor))
            }
            .font(.title3)
            
            HStack {
                Label("Parts in cycles:",
                      systemImage: "arrow.3.trianglepath")
                
                Spacer()
                
                let cyclicPortion = artifactVM.codeArtifact.metrics.portionOfPartsInCycles
                
                let cycleColor = Color.rgb(0, 1, 0)
                    .mixed(with: cyclicPortion, of: .rgb(1, 0, 0))
                
                Text("\(Int(cyclicPortion * 100))%")
                    .foregroundColor(SwiftUI.Color(cycleColor))
            }
            .font(.title3)
        }
        .focusable(false)
    }
    
    let artifactVM: ArtifactViewModel
}


extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
