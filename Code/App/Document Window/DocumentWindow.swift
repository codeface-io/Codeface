import SwiftLSP
import Foundation
import Combine
import SwiftyToolz

@MainActor
class DocumentWindow: ObservableObject
{
    // MARK: - Initialize
    
    init(codebase: CodeFolder?)
    {
        _lastLocation = Published(initialValue: try? CodebaseLocationPersister.loadCodebaseLocation())
        
        if let codebase { runProcessor(with: codebase) }
        
        sendEventWhenProcessorDidRetrieveNewCodebase()
    }
    
    private func sendEventWhenProcessorDidRetrieveNewCodebase()
    {
        processorObservation = codebaseProcessor.$state.sink
        {
            if case .didJustRetrieveCodebase(let codebase) = $0
            {
                self.send(.didRetrieveNewCodebase(codebase))
            }
        }
    }
    
    private var processorObservation: AnyCancellable?
    
    // MARK: - Run Processor with Codebase at Location
    
    func runProcessorWithSwiftPackageCodebase(at folderURL: URL)
    {
        runProcessor(withCodebaseAtNewLocation: .init(folder: folderURL,
                                                        languageName: "Swift",
                                                        codeFileEndings: ["swift"]))
    }
    
    func runProcessorWithLastCodebaseIfNoneIsLoaded()
    {
        if CodebaseLocationPersister.hasPersistedLastCodebaseLocation
        {
            runProcessorWithLastCodebase()
        }
    }
    
    func runProcessorWithLastCodebase()
    {
        do
        {
            try runProcessor(withCodebaseAt: CodebaseLocationPersister.loadCodebaseLocation())
        }
        catch { log(error.readable) }
    }
    
    func runProcessor(withCodebaseAtNewLocation location: LSP.CodebaseLocation)
    {
        do
        {
            try runProcessor(withCodebaseAt: location)
            try CodebaseLocationPersister.persist(location)
        }
        catch { log(error.readable) }
    }
    
    private func runProcessor(withCodebaseAt location: LSP.CodebaseLocation) throws
    {
        guard FileManager.default.itemExists(location.folder) else
        {
            throw "Project folder does not exist: " + location.folder.absoluteString
        }
        
        runProcessor(from: .didLocateCodebase(location))
        lastLocation = location
    }
    
    @Published var lastLocation: LSP.CodebaseLocation?
    
    // MARK: - Load Processor for Codebase from File
    
    func runProcessor(withCodebaseAt fileURL: URL)
    {
        guard let fileData = Data(from: fileURL) else
        {
            log(error: "Couldn't read codebase file")
            return
        }
        
        guard let codebase = CodeFolder(fileData) else
        {
            log(error: "Couldn't decode codebase")
            return
        }
        
        runProcessor(with: codebase)
    }
    
    func runProcessor(with codebase: CodeFolder)
    {
        runProcessor(from: .processCodebase(codebase,
                                            .init(primaryText: "Did Load Codebase Data",
                                                  secondaryText: "")))
    }
    
    // MARK: - Load Processor
    
    private func runProcessor(from state: CodebaseProcessorState)
    {
        codebaseProcessor.state = state
        codebaseProcessor.run()
    }
    
    // MARK: - Observable Events
    
    private func send(_ event: Event)
    {
        events.send(event)
    }
    
    let events = CombineMessenger<Event>()
    
    enum Event
    {
        case didRetrieveNewCodebase(CodeFolder)
    }
    
    typealias CombineMessenger<Message> = PassthroughSubject<Message, Never>
    
    // MARK: - Codebase Processor
    
    let codebaseProcessor = CodebaseProcessor()
    
    // MARK: - Import Views
    
    @Published var isPresentingCodebaseLocator = false
    @Published var isPresentingFolderImporter = false
    
    // MARK: - Display Options
    
    @Published var displayOptions = AnalysisDisplayOptions()
}
