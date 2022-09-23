import SwiftyToolz

func generatePrivacyPage(siteFolder: SiteFolder) throws
{
    let privacyPageHTML = try generatePrivacyPageHTML(siteFolder: siteFolder)
    
    let filePath = "privacy-policy/index.html"
    try siteFolder.write(text: privacyPageHTML, toFile: filePath)
    log("Did write: \(filePath) ✅")
}

private func generatePrivacyPageHTML(siteFolder: SiteFolder) throws -> String
{
    let contentHTML = try siteFolder.read(file: "privacy-policy/page_content.html")
    
    return generateCodefacePageHTML(rootPath: "../",
                                    blogPath: "../blog/",
                                    cssFiles: ["../codeface.css", "../blog/page_style.css"],
                                    contentHTML: contentHTML)
}
