func generatePageHTML(metaData: PageMetaData,
                      canonicalURL: String,
                      cssFiles: [String],
                      bodyContentHTML: String,
                      script: String) -> String
{
    let cssFilesHTML = cssFiles
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
            <meta property="og:title" content="\(metaData.title)"/>
            <meta property="og:site_name" content="\(metaData.title)"/>
    
            <!-- Author -->
            <meta name="author" content="\(metaData.author)"/>
    
            <!-- Description -->
            <meta name="description" content="\(metaData.description)"/>
            <meta property="og:description" content="\(metaData.description)"/>
    
            <!-- Keywords -->
            <meta name="keywords" content="\(metaData.keywords)"/>
    
            <!-- Canonical Link -->
            <link rel="canonical" href="\(canonicalURL)">
    
            <!-- CSS Files -->
            \(cssFilesHTML.with(newlineIndentations: 2))
        </head>
    
        <body>
            \(bodyContentHTML.with(newlineIndentations: 2))
        </body>
    
        <!-- Load scripts at the very end for performance -->
        <script>
        \(script.with(newlineIndentations: 1))
        </script>
    </html>
    """
    
    /* potential other head content
     // for image source on blog posts: use poster image from post meta data!
     <!-- Site Icon -->
     <link rel="apple-touch-icon" sizes="180x180" href="/assets/icon/apple-touch-icon.png">
     <link rel="icon" type="image/png" sizes="32x32" href="/assets/icon/favicon-32x32.png">
     <link rel="manifest" href="/assets/icon/site.webmanifest">
     <link rel="mask-icon" href="/assets/icon/safari-pinned-tab.svg" color="#000000">
     <meta name="msapplication-TileColor" content="#000000">
     <meta name="theme-color" content="#ffffff">

     <!-- URL -->
     <link rel="canonical" href="http://localhost:4000/">
     <meta property="og:url" content="http://localhost:4000/" />
  
     <!-- Image -->
     <link rel="image_src" href="http://localhost:4000">
     <meta property="og:image" content="http://localhost:4000" />
     <meta property="og:image:type" content="image/jpeg" />
     */
}

extension String
{
    func with(newlineIndentations: Int) -> String
    {
        var newlinePrefix = ""
        newlineIndentations.times { newlinePrefix += "    " }
        return replacingOccurrences(of: "\n", with: "\n" + newlinePrefix)
    }
}

struct PageMetaData
{
    let title: String
    let author: String
    let description: String
    let keywords: String
}
