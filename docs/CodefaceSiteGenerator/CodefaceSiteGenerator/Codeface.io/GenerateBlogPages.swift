import FoundationToolz
import Foundation
import SwiftyToolz

func generateBlogPages(siteFolder: SiteFolder) throws
{
    let blogPageHTML = try generateBlogPageHTML(siteFolder: siteFolder)
    let filePath = "blog/index.html"
    try siteFolder.write(text: blogPageHTML, toFile: filePath)
    log("Did write: \(filePath) ✅")
    
    try generateAndWriteBlogPostPages(siteFolderURL: siteFolder.url)
}

private func generateBlogPageHTML(siteFolder: SiteFolder) throws -> String
{
    let postsFolder = siteFolder.url + "blog/posts"
    
    let postFolders = FileManager.default.items(inDirectory: postsFolder,
                                                recursive: false)
    
    let postListHTML: String = postFolders
        .map {
            
            let metaDataFile = $0 + postMetaDataFileName
            let postMetaData = PostMetaData(from: metaDataFile)
            
            if postMetaData == nil
            {
                log(warning: "No \(postMetaDataFileName) file in folder: \($0.lastPathComponent) ❌")
            }
            
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
                                    cssFiles: ["../codeface.css", "page_style.css"],
                                    contentHTML: contentHTML)
}

private func generatePostOverviewHTML(with metaData: PostMetaData, folderName: String) -> String
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

private func generateAndWriteBlogPostPages(siteFolderURL: URL) throws
{
    let postsFolder = siteFolderURL + "blog/posts"
    
    let postFolders = FileManager.default.items(inDirectory: postsFolder,
                                                recursive: false)
    
    for postFolder in postFolders
    {
        let postMetaDataFile = postFolder + postMetaDataFileName
        let postMetaData = PostMetaData(from: postMetaDataFile)
        
        if postMetaData == nil
        {
            log(warning: "No \(postMetaDataFileName) file in folder: \(postFolder.lastPathComponent) ❌")
        }
        
        let defaultTitle = postFolder
            .lastPathComponent
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
        
        let title = postMetaData?.title ?? defaultTitle
        let date = postMetaData?.date?.displayString ?? ""
        let author = postMetaData?.author ?? "Sebastian Fichtner"
        let dateAndAuthor = date + " • " + author
        
        let postContentHTML = try (postFolder + "post_content.html").readText()
        
        let postPageBodyContentHTML =
        """
        <section>
            <div>
                <h1 style="margin-bottom:30px">\(title)</h1>
        
                <p style="text-align:center" class="secondary-text-color">\(dateAndAuthor)</p>
                \(postContentHTML)
            </div>
        </section>
        """
        
        let postPageHTML = generateCodefacePageHTML(rootPath: "../../../",
                                                    cssFiles: ["../../../codeface.css", "../../page_style.css"],
                                                    contentHTML: postPageBodyContentHTML)
        
        let fileName = "index.html"
        try (postFolder + fileName).write(text: postPageHTML)
        log("Did write: \(postFolder.lastPathComponent)/\(fileName) ✅")
    }
}

private var postMetaDataFileName: String { "post_meta_data.json" }
