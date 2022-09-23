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
    
    return generateCodefacePageHTML(rootPath: "",
                                    blogPath: "blog/",
                                    cssFiles: ["codeface.css", "app/page_style.css"],
                                    contentHTML: contentHTML,
                                    script: script)
}

func generateBlogPageHTML(siteFolder: SiteFolder) throws -> String
{
    let postsFolder = siteFolder.url.appendingPathComponent("blog/posts")
    
    let postFolders = FileManager.default.items(inDirectory: postsFolder,
                                                recursive: false)
    
    let postListHTML: String = postFolders
        .map {
            let metaDataFile = $0.appendingPathComponent("post_meta_data.json")
            let postMetaData = PostMetaData(from: metaDataFile)
            
            log("found\(postMetaData == nil ? " no " : " ")post meta data in folder: \($0.lastPathComponent) \(postMetaData != nil ? "✅" : "❌")")
            
            return ($0, postMetaData ?? .init())
        }
        .sorted {
            $0.1 < $1.1 // sort by date
        }
        .map {
            generatePostOverviewHTML(with: $1, folderName: $0.lastPathComponent)
        }
        .joined(separator: "\n\n        ")
    
    let contentHTML =
    """
    <section>
        <div class="blog-post-list-wrapper">
            \(postListHTML)
        </div>
    </section>
    """
    
    return generateCodefacePageHTML(rootPath: "../",
                                    blogPath: "",
                                    cssFiles: ["../codeface.css", "page_style.css"],
                                    contentHTML: contentHTML)
}

func generatePostOverviewHTML(with metaData: PostMetaData, folderName: String) -> String
{
    """
    <h2><a class="subtle-link" href="posts/\(folderName)/index.html">\(metaData.title ?? folderName)</a></h2>
    
    <div class="blog-post-grid">
        <a href="posts/\(folderName)/index.html">
            <img class="blog-post-image" src="posts/\(folderName)/\(metaData.posterImage ?? "")"></img>
        </a>
        <div>
            <p class="secondary-text-color">\(metaData.date?.displayString ?? "")</p>
            <p>
            \(metaData.excerpt ?? "")
            </p>
        </div>
    </div>
    """
}

func generatePrivacyPageHTML(siteFolder: SiteFolder) throws -> String
{
    let contentHTML = try siteFolder.read(file: "privacy-policy/page_content.html")
    
    return generateCodefacePageHTML(rootPath: "../",
                                    blogPath: "../blog/",
                                    cssFiles: ["../codeface.css", "../blog/page_style.css"],
                                    contentHTML: contentHTML)
}

func generateCodefacePageHTML(rootPath: String,
                              blogPath: String,
                              cssFiles: [String] = [],
                              contentHTML: String,
                              script: String = "") -> String
{
    let metaData = PageMetaData(title: "Codeface",
                                author: "Sebastian Fichtner",
                                description: "See the Architecture of any Codebase",
                                keywords: "macOS, Swift, software architecture, app, codeface, codebase")
    
    let navBarHTML = generateNavigationBarHTML(rootPath: rootPath, blogPath: blogPath)
    let footerHTML = generateFooterHTML(rootPath: rootPath)
    let bodyContentHTML = navBarHTML + "\n\n" + contentHTML + "\n\n" + footerHTML
    
    return generatePageHTML(metaData: metaData,
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
                <a href="\(rootPath)privacy-policy/index.html">Privacy Policy</a>
            </div>
            <div style="text-align: right">
                Copyright &copy; 2022 <a href="https://www.flowtoolz.com">Flowtoolz.com</a>
            </div>
        </div>
    </section>
    """
}
