import SwiftUI

struct ConcurrencyPOCView: View
{
    var body: some View
    {
        VStack
        {
            Text("Number = \(viewModel.number)")
            
            Button("Start")
            {
                Task // just to have an async context
                {
                    let bgCalcResult = await viewModel.calculateInBackground()
                    
                    result = "\(bgCalcResult)"
                }
            }
            
            Text("Result: \(result)")
        }
    }
    
    @StateObject private var viewModel = ViewModel()
    @State private var result = ""
}

@MainActor // vm is on main actor so view can observe it
class ViewModel: ObservableObject
{
    func calculateInBackground() async -> Int
    {
        // ❗️ rather remember the task if we have to cancel it
        await Task.detached // leave main actor to not block it
        {
            for _ in 1 ... 10000 // ❗️ also check Task.isCancelled if it might be cancelled
            {
                await MainActor.run // go back to main actor for progress update
                {
                    self.number += 1
                }
            }
            
            return 1234567
        }
        .value
    }
    
    @Published var number = 0
}
