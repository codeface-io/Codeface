import FoundationToolz
import Foundation
import Combine
import SwiftLSP
import SwiftyToolz

@MainActor
class CodebaseProcessor: ObservableObject
{
    // MARK: - Run Processing
    
    func run()
    {
        Task // to enter an async context
        {
            // get codebase
            guard let codebase = await retrieveCodebase() else { return }
            
            // generate architecture
            state = .processCodebase(codebase, .init(primaryText: "Generating Codebase Architecture",
                                                     secondaryText: ""))
            let codebaseArchitecture = await CodebaseProcessorSteps.generateArchitecture(from: codebase)
            
            // calculate metrics
            state = .processArchitecture(codebase,
                                         codebaseArchitecture,
                                         .init(primaryText: "Calculating Codebase Architecture Metrics",
                                               secondaryText: ""))
            await codebaseArchitecture.calculateMetrics()
            
            // create view model
            state = .processArchitecture(codebase,
                                         codebaseArchitecture,
                                         .init(primaryText: "Generating Codebase Architecture View Models",
                                               secondaryText: ""))
            let architectureViewModel = await ArtifactViewModel(folderArtifact: codebaseArchitecture,
                                                                isPackage: codebase.looksLikeAPackage)
            architectureViewModel.addDependencies()
            
            state = .analyzeArchitecture(.init(rootArtifact: architectureViewModel))
        }
    }
    
    private func retrieveCodebase() async -> CodeFolder?
    {
        switch state
        {
        case .didJustRetrieveCodebase(let codebase):
            return codebase
            
        case .didLocateCodebase(let codebaseLocation):
            state = .retrieveCodebase("Reading raw data from codebase folder")
            guard let codebaseWithoutSymbols = await readCodebaseFolder(from: codebaseLocation) else
            {
                return nil
            }
            
            do
            {
                state = .retrieveCodebase("Connecting to LSP server")
                let server = try await LSP.ServerManager.shared.initializeServer(for: codebaseLocation)
                
                state = .retrieveCodebase("Retrieving symbols and their references from LSP server")
                
                let codebase = try await CodebaseProcessorSteps.retrieveSymbolsAndReferences(for: codebaseWithoutSymbols,
                                                                                             from: server,
                                                                                             codebaseRootFolder: codebaseLocation.folder)
                
                state = .didJustRetrieveCodebase(codebase)
                return codebase
            }
            catch
            {
                log(warning: "Cannot talk to LSP server: " + error.readable.message)
                LSP.ServerManager.shared.serverIsWorking = false
                
                state = .didJustRetrieveCodebase(codebaseWithoutSymbols)
                return codebaseWithoutSymbols
            }
            
        case .processCodebase(let codebase, _):
            return codebase
            
        case .processArchitecture(let codebase, _, _):
            return codebase
            
        default:
            log(error: "Processor can't retrieve codebase as it is in state \(state)")
            return nil
        }
    }
    
    private func readCodebaseFolder(from codebaseLocation: LSP.CodebaseLocation) async -> CodeFolder?
    {
        do
        {
            return try await CodebaseProcessorSteps.readFolder(from: codebaseLocation)
        }
        catch
        {
            log(error.readable.message)
            state = .didFail(error.readable.message)
            return nil
        }
    }
    
    // MARK: - State
    
    @Published var state = CodebaseProcessorState.empty
}
