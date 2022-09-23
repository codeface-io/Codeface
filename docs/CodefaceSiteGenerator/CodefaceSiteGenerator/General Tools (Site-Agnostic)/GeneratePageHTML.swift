func generatePageHTML(metaData: PageMetaData,
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
    
        <!-- Load scripts at the very end for performance -->
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

struct PageMetaData
{
    let title: String
    let author: String
    let description: String
    let keywords: String
}
