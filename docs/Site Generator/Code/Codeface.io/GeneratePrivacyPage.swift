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
    let filePath = "privacy-policy/page_content.html"
    let contentHTML = try siteFolder.read(file: filePath)
    
    return generateCodefacePageHTML(rootPath: "../",
                                    filePathRelativeToRoot: filePath,
                                    cssFiles: ["../codeface.css", "../blog/page_style.css"],
                                    bodyContentHTML: contentHTML)
}
