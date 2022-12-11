import SwiftUIToolzOLD
import SwiftUI
import SwiftLSP
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
//                .onChange(of: isSearching)
//                {
//                    [isSearching] isSearchingNow in
//                    
//                    guard isSearching != isSearchingNow else { return }
//                    
//                    analysisVM.isTypingSearch = isSearchingNow
//                }
//                .onReceive(analysisVM.$isTypingSearch)
//                {
//                    if !$0 { dismissSearch() }
//                }
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
                    if artifactVM.filteredParts.isEmpty
                    {
                        let contentIsFilteredOut = !artifactVM.passesSearchFilter || !artifactVM.parts.isEmpty
                        
                        if contentIsFilteredOut
                        {
                            VStack(alignment: .center)
                            {
                                Label("No Search Results", systemImage: "xmark.rectangle")
                                    .foregroundColor(.secondary)
                                    .font(.system(.title))
                                    .padding(.bottom)
                                
                                Text(artifactVM.codeArtifact.name + " does not contain the term \"\(processorVM.appliedSearchTerm ?? "")\"")
                                    .foregroundColor(.secondary)
                                    .padding(.bottom)
                                
                                Button("Remove Search Filter", role: .destructive)
                                {
                                    processorVM.removeSearchFilter()
                                }
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
                                
                                //Main
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
                                HStack(spacing: 0) {
                                    Divider()
                                        .frame(minWidth: 0)
                                    
                                    List {
                                        Text("Inspector Element 1")
                                        Text("Inspector Element 2")
                                        Text("Inspector Element 3")
                                        Text("Inspector Element 4")
                                        Text("Inspector Element 5")
                                    }
                                    .focusable(false)
                                    .listStyle(.sidebar)
                                }
                                .frame(width: showsInspector ? max(250, geo.size.width / 4) : 0)
                                .opacity(showsInspector ? 1 : 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .toolbar {
//                                Button(action: { codefaceDocument.loadProcessorForLastCodebase() })
//                                {
//                                    Image(systemName: "arrow.clockwise")
//                                }
//                                .disabled(!CodebaseLocationPersister.hasPersistedLastCodebaseLocation)
//                                .help("Import the last imported folder again")
//
//                                Spacer()
                                
                                if let searchTerm = processorVM.appliedSearchTerm, !searchTerm.isEmpty
                                {
                                    FilterRemovalButton(processorVM: processorVM)
                                }
                                
                                // TODO: fext field in toolbar does not recognize its focus ...
                                SearchField()
                                
                                Spacer()
                                
                                DisplayModePicker(displayMode: $processorVM.displayMode)
                                
                                Button {
                                    withAnimation {
                                        showsInspector.toggle()
                                    }
                                } label: {
                                    Image(systemName: "sidebar.right")
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
//            .searchable(text: $searchTerm,
//                        placement: .toolbar,
//                        prompt: searchPrompt)
//            .onSubmit(of: .search)
//            {
//                processorVM.isTypingSearch = false
//            }
//            .onChange(of: searchTerm)
//            {
//                [searchTerm] newSearchTerm in
//                
//                guard searchTerm != newSearchTerm else { return }
//                
//                withAnimation(.easeInOut)
//                {
//                    processorVM.userChanged(searchTerm: newSearchTerm)
//                }
//            }
//            .onReceive(processorVM.$isTypingSearch)
//            {
//                if $0 { searchTerm = processorVM.appliedSearchTerm ?? "" }
//            }
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
    
//    @Environment(\.isSearching) private var isSearching
//    @Environment(\.dismissSearch) private var dismissSearch
//    @FocusState private var listIsInFocus
}

extension ArtifactViewModel
{
    var children: [ArtifactViewModel]?
    {
        parts.isEmpty ? nil : parts
    }
}
