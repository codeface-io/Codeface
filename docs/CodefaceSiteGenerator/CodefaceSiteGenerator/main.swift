import FoundationToolz
import Foundation
import SwiftyToolz

do
{
    let siteFolder = try SiteFolder(path: getSiteFolderPath())
    
    let rootPageHTML = try generateRootPageHTML(siteFolder: siteFolder)
    try siteFolder.write(html: rootPageHTML, toFile: "index.html")
    
    let blogPageHTML = try generateBlogPageHTML(siteFolder: siteFolder)
    try siteFolder.write(html: blogPageHTML, toFile: "blog/index.html")
    
    let privacyPageHTML = try generatePrivacyPageHTML(siteFolder: siteFolder)
    try siteFolder.write(html: privacyPageHTML, toFile: "privacy-policy/index.html")
}
catch
{
    print(error.localizedDescription)
}

func getSiteFolderPath() -> String
{
    "/Users/seb/Desktop/GitHub Repos/Codeface/docs"
//    Bundle.main.bundlePath
}

func generateRootPageHTML(siteFolder: SiteFolder) throws -> String
{
    let contentHTML = try siteFolder.read(file: "app/page_content.html")
    
    let script =
    """
    // Toggle Screenshots Between Light and Dark
    function toggleLightMode(idString)
    {
        document.getElementById(idString).classList.toggle("light-mode");
        //console.log(document.getElementById("screen-shot-1").classList);
    }
    """
    
    return generatePageHTML(rootPath: "",
                            blogPath: "blog/",
                            cssFiles: ["codeface.css", "app/page_style.css"],
                            contentHTML: contentHTML,
                            script: script)
}

func generateBlogPageHTML(siteFolder: SiteFolder) throws -> String
{
    let contentHTML = try siteFolder.read(file: "blog/page_content.html")
    
    return generatePageHTML(rootPath: "../",
                            blogPath: "",
                            cssFiles: ["../codeface.css", "page_style.css"],
                            contentHTML: contentHTML)
}

func generatePrivacyPageHTML(siteFolder: SiteFolder) throws -> String
{
    let contentHTML = try siteFolder.read(file: "privacy-policy/page_content.html")
    
    return generatePageHTML(rootPath: "../",
                            blogPath: "../blog/",
                            cssFiles: ["../codeface.css", "../blog/page_style.css"],
                            contentHTML: contentHTML)
}

func generatePageHTML(rootPath: String,
                      blogPath: String,
                      cssFiles: [String] = [],
                      contentHTML: String,
                      script: String = "") -> String
{
    let metaData = MetaData(title: "Codeface",
                            author: "Sebastian Fichtner",
                            description: "See the Architecture of any Codebase",
                            keywords: "macOS, Swift, software architecture, app, codeface, codebase")
    
    let navBarHTML = generateNavigationBarHTML(rootPath: rootPath, blogPath: blogPath)
    let footerHTML = generateFooterHTML(rootPath: rootPath)
    let bodyContentHTML = navBarHTML + "\n\n" + contentHTML + "\n\n" + footerHTML
    
    return htmlDocument(metaData: metaData,
                        cssFiles: cssFiles,
                        bodyContent: bodyContentHTML,
                        script: script)
}

func generateNavigationBarHTML(rootPath: String, blogPath: String) -> String
{
    """
    <section id="codeface-navbar" class="codeface-bar">
        <div>
            <a href="\(rootPath)index.html"><img style="float:left;margin-top:4px;margin-right:10px;px;width:55px;heigh:55px;" src="\(rootPath)app/icon_1024.png"></img></a>
            <ul>
                <li class="left"><a class="subtle-link" href="\(blogPath)index.html">Blog</a></li>
                <li class="left"><a class="subtle-link" href="\(rootPath)index.html#contact">Contact</a></li>
                <li class="right desktop-only"><a onclick="ga('send', 'event', 'button', 'click', 'navigation bar');"
                    href="https://apps.apple.com/app/codeface/id1578175415"
                    target="_blank">
                    <img style="width:180px"
                        src="\(rootPath)app/App_Store_Badge.svg"
                        title="Download Codeface for free from the Mac App Store"></a>
                </li>
            </ul>
        </div>
    </section>
    """
}

func generateFooterHTML(rootPath: String) -> String
{
    """
    <section id="codeface-bottom-bar" class="codeface-bar">
        <div style="display:grid;grid-template-columns:50% 50%;column-gap:0%;">
            <div style="text-align: left">
                <a href="\(rootPath)privacy-policy.html">Privacy Policy</a>
            </div>
            <div style="text-align: right">
                Copyright &copy; 2022 <a href="https://www.flowtoolz.com">Flowtoolz.com</a>
            </div>
        </div>
    </section>
    """
}

// MARK: - General Tools (Site-Agnostic)

func htmlDocument(metaData: MetaData,
                  cssFiles: [String],
                  bodyContent: String,
                  script: String) -> String
{
    let cssFileHTML = cssFiles
        .map {
            "<link rel=\"stylesheet\" href=\"\($0)\">"
        }
        .joined(separator: "\n")
    
    return """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <!-- General Meta Data Stuff -->
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
    
            <meta property="og:type" content="website"/>
            <meta property="og:locale" content="en_US">
            <meta property="og:locale:alternate" content="en_GB">
            <meta property="og:locale:alternate" content="de_DE">
            
            <!-- Title -->
            <title>\(metaData.title)</title>
            <meta name="twitter:title" content="\(metaData.title)"/>
            <meta name="og:title" content="\(metaData.title)"/>
            <meta property="og:title" content="\(metaData.title)" />
            <meta property="og:site_name" content="\(metaData.title)" />
    
            <!-- Author -->
            <meta name="author" content="\(metaData.author)"/>
    
            <!-- Description -->
            <meta name="description" content="\(metaData.description)"/>
            <meta property="og:description" content="\(metaData.description)"/>
    
            <!-- Keywords -->
            <meta name="keywords" content="\(metaData.keywords)"/>
    
            <!-- START: CSS FILES INSERTED BY SITE GENERATOR -->
            \(cssFileHTML)
            <!-- END: CSS FILES INSERTED BY SITE GENERATOR -->
        </head>
        <body>
        <!-- START: BODY CONTENT INSERTED BY SITE GENERATOR -->
        \(bodyContent)
        <!-- END: BODY CONTENT INSERTED BY SITE GENERATOR -->
        </body>
    
        <script>
        // START: SCRIPT INSERTED BY SITE GENERATOR
        \(script)
        // END: SCRIPT INSERTED BY SITE GENERATOR
        </script>
    </html>
    """
    
    /* potential other head content
     
     <!-- Site Icon -->
     <link rel="apple-touch-icon" sizes="180x180" href="/assets/icon/apple-touch-icon.png">
     <link rel="icon" type="image/png" sizes="32x32" href="/assets/icon/favicon-32x32.png">
     <link rel="manifest" href="/assets/icon/site.webmanifest">
     <link rel="mask-icon" href="/assets/icon/safari-pinned-tab.svg" color="#000000">
     <meta name="msapplication-TileColor" content="#000000">
     <meta name="theme-color" content="#ffffff">

     <!-- URL -->
     <meta property="og:url" content="http://localhost:4000/" />
  
     <!-- Image -->
     <link rel="image_src" href="http://localhost:4000">
     <meta property="og:image" content="http://localhost:4000" />
     <meta property="og:image:type" content="image/jpeg" />
     */
}

struct MetaData
{
    let title: String
    let author: String
    let description: String
    let keywords: String
}

struct SiteFolder
{
    init(path: String) throws
    {
        guard FileManager.default.fileExists(atPath: path) else
        {
            throw "Folder doesn't exist: " + path
        }
    
        url = URL(fileURLWithPath: path)
        
        log("Found site folder: \(url.lastPathComponent) ✅")
    }
    
    func read(file filePath: String) throws -> String
    {
        let file = url.appendingPathComponent(filePath)
        return try String(contentsOf: file, encoding: .utf8)
    }
    
    func write(html: String, toFile filePath: String) throws
    {
        let file = url.appendingPathComponent(filePath)
        try html.write(to: file, atomically: true, encoding: .utf8)
        log("Did write: \(filePath) ✅")
    }
    
    let url: URL
}
