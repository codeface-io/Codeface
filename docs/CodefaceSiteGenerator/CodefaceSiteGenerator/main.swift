import Foundation

do
{
    let siteFolder = try SiteFolder(path: "/Users/seb/Desktop/GitHub Repos/Codeface/docs")
    
    try generateRootPage(siteFolder: siteFolder)
    try generatePrivacyPage(siteFolder: siteFolder)
    try generateBlogPages(siteFolder: siteFolder)
}
catch
{
    print(error.localizedDescription)
}