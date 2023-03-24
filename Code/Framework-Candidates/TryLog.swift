import Foundation
import SwiftyToolz

func tryAwaitLog(_ action: @Sendable () async throws -> Void) async
{
    do
    {
        try await action()
    }
    catch
    {
        log(error: error.localizedDescription)
    }
}
