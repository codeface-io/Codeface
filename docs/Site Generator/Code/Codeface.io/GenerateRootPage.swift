import SwiftyToolz

func generateRootPage(siteFolder: SiteFolder) throws
{
    let rootPageHTML = try generateRootPageHTML(siteFolder: siteFolder)
    let fileName = "index.html"
    try siteFolder.write(text: rootPageHTML, toFile: fileName)
    log("Did write: \(fileName) ✅")
}

private func generateRootPageHTML(siteFolder: SiteFolder) throws -> String
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
                                    filePathRelativeToRoot: "index.html",
                                    cssFiles: ["codeface.css", "app/page_style.css"],
                                    bodyContentHTML: contentHTML,
                                    script: script)
}
