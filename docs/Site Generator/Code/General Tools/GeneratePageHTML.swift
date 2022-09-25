func generatePageHTML(metaData: PageMetaData,
                      imageURL: String,
                      canonicalURL: String,
                      cssFiles: [String],
                      otherHeadContent: String? = nil,
                      bodyContentHTML: String,
                      script: String) -> String
{
    let imageType: String = imageURL.hasSuffix(".png") ? "image/png" : "image/jpeg"
    
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
            <meta name="theme-color" content="#000000">
    
            <meta property="og:type" content="\(metaData.ogType)"/>
            <meta property="og:locale" content="en_US">
            <meta property="og:locale:alternate" content="en_GB">
            <meta property="og:locale:alternate" content="de_DE">
            
            <!-- Title -->
            <title>\(metaData.title)</title>
            <meta name="twitter:title" content="\(metaData.title)"/>
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
            <meta property="og:url" content="\(canonicalURL)"/>
    
            <!-- Image -->
            <link rel="image_src" href="\(imageURL)">
            <meta property="og:image" content="\(imageURL)"/>
            <meta property="og:image:type" content="\(imageType)"/>
    
            <!-- CSS Files -->
            \(cssFilesHTML.with(newlineIndentations: 2))
    
            \(otherHeadContent?.with(newlineIndentations: 2) ?? "")
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
    init(title: String,
         author: String,
         description: String,
         keywords: String,
         ogType: String? = nil)
    {
        self.title = title
        self.author = author
        self.description = description
        self.keywords = keywords
        self.ogType = ogType ?? "website"
    }
    
    let title: String
    let author: String
    let description: String
    let keywords: String
    let ogType: String
}
