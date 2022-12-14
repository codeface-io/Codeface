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
            NavigationSplitView(columnVisibility: $columnVisibility)
            {
                List([rootArtifact],
                     children: \.children,
                     selection: $codefaceDocument.selectedArtifact)
                {
                    artifactVM in
                    
                    NavigationLink(value: artifactVM) {
                        SidebarLabel(artifact: artifactVM,
                                     isSelected: artifactVM == codefaceDocument.selectedArtifact)
                    }
                }
                .navigationSplitViewColumnWidth(min: 250, ideal: 250)
                
//                .onAppear
//                {
//                    selectedArtifact = rootArtifact
//                    listIsInFocus = true
//                }
//                .focused($listIsInFocus)
            }
            detail:
            {
                if let artifactVM = codefaceDocument.selectedArtifact
                {
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
                                    withAnimation
                                    {
                                        processorVM.searchVM.searchBarIsShown = false
                                    }
                                }
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
                            GeometryReader { geo in
                                
                                HStack(spacing: 0) {
                                    
                                    // Main
                                    VStack {
                                        switch processorVM.displayMode
                                        {
                                        case .treeMap: TreeMap(rootArtifactVM: artifactVM,
                                                               viewModel: processorVM)
                                        case .code: CodeView(artifact: artifactVM)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    
                                    // Inspector
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
                                    .background(.green)
                                    .frame(width: showsInspector ? max(250, geo.size.width / 5) : 0)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .toolbar
                                {
                                    //                                Button(action: { codefaceDocument.loadProcessorForLastCodebase() })
                                    //                                {
                                    //                                    Image(systemName: "arrow.clockwise")
                                    //                                }
                                    //                                .disabled(!CodebaseLocationPersister.hasPersistedLastCodebaseLocation)
                                    //                                .help("Import the last imported folder again")
                                    //
                                    //                                Spacer()
                                    
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
                                    
                                    ToolbarItemGroup(placement: ToolbarItemPlacement.primaryAction)
                                    {
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                showsInspector.toggle()
                                            }
                                        } label: {
                                            Image(systemName: "sidebar.right")
                                        }
                                        .help("Toggle the inspector on the right (⌥⌘0)")
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    Text("Select a code artifact in the navigator on the left.")
                }
            }
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
    
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var showsInspector: Bool
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
    
//    @FocusState private var listIsInFocus
}

extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
