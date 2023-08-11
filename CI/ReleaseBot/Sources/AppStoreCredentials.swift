import Foundation

struct AppStoreCredentials {

    /// reads command line arguments first. if they're not provided, it looks for files temporarily provided during development. if there are no files, it asks the user to type name and password.
    static func retrieve() throws -> AppStoreCredentials {
        // 1. command line
        
        let arguments = CommandLine.arguments

        if arguments.count == 3 {
            return .init(username: arguments[1], password: arguments[2])
        }
        
        print("🤖 Usage: ReleaseBot <username> <password>")
        
        // 2. dev files
        
        let devCICredentialsFolder = "/Users/seb/Library/Mobile Documents/com~apple~CloudDocs/iCloud/SOFTWARE DEV/Codeface Private/Development/CI credentials"
        
        let usernameFile = devCICredentialsFolder + "/app_store_connect_user.txt"
        let passwordFile = devCICredentialsFolder + "/app_store_connect_password.txt"
        
        if let username = try? String(contentsOfFile: usernameFile),
           let password = try? String(contentsOfFile: passwordFile) {
            return .init(username: username, password: password)
        }
            
        // 3. user input
            
        print("Enter username:")
        let username = readLine(strippingNewline: true) ?? ""
        
        print("Enter password:")
        let password = readLine(strippingNewline: true) ?? ""
        
        return .init(username: username, password: password)
    }
    
    let username: String
    let password: String
}
