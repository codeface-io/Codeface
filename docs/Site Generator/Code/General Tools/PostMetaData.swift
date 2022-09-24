import FoundationToolz
import Foundation

struct PostMetaData: Codable, Comparable
{
    static func < (lhs: PostMetaData, rhs: PostMetaData) -> Bool
    {
        guard let leftDate = lhs.date,
              let rightDate = rhs.date else { return lhs.date != nil }
        
        return leftDate < rightDate
    }
    
    internal init(title: String? = nil,
                  posterImage: String? = nil,
                  date: PostMetaData.PublishDate? = nil,
                  author: String? = nil,
                  excerpt: String? = nil)
    {
        self.title = title
        self.posterImage = posterImage
        self.date = date
        self.author = author
        self.excerpt = excerpt
    }
        
    static var example: PostMetaData
    {
        .init(title: "Example Title",
              posterImage: "images/poster.png",
              date: PublishDate(year: 2022, month: 11, day: 3),
              excerpt: "Example excerpt from example post meta data")
    }
    
    let title: String?
    let posterImage: String?
    let date: PublishDate?
    let author: String?
    let excerpt: String?
    
    struct PublishDate: Codable, Comparable
    {
        static func < (lhs: PublishDate, rhs: PublishDate) -> Bool
        {
            if lhs.year > rhs.year { return true }
            if lhs.month > rhs.month { return true }
            return lhs.day > rhs.day
        }
        
        var displayString: String
        {
            guard let date = Date(year: year, month: month, day: day) else
            {
                return "\(day).\(month).\(year)"
            }
            
            return date.string(withFormat: "MMMM d, yyyy")
        }
        
        let year: Int
        let month: Int
        let day: Int
    }
}
