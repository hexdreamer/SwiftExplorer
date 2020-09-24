
import Foundation

struct SEDecodableItem : Decodable {
    
    let contentEncoded:String?
    let description:String?
    let descriptionData:Data?
    let enclosure:SEDecodableEnclosure?
    let guid:String
    let itunesDuration:String
    let itunesEpisodeType:String?
    let itunesExplicit:Bool?
    let itunesImage:URL?
    let itunesKeywords:String?
    let itunesSubtitle:String?
    let itunesSummaryData:Data?
    let link:URL
    let pubDate:Date
    let title:String
    
    public var itemDescription:String {
        if let data = self.descriptionData {
            let htmlConverter = SEHTMLToUnicode()
            return htmlConverter.parse(data)
        }
        return "NO DESCRIPTION"
    }

    public var itunesSummary:String {
        if let data = self.itunesSummaryData {
            let htmlConverter = SEHTMLToUnicode()
            return htmlConverter.parse(data)
        }
        return "NO SUMMARY"
    }

    enum CodingKeys: String, CodingKey {
        case contentEncoded    = "content:encoded"
        case description
        case descriptionData   = "description@"
        case enclosure
        case guid
        case itunesDuration    = "itunes:duration"
        case itunesEpisodeType = "itunes:episodetype"
        case itunesExplicit    = "itunes:explicit"
        case itunesImage       = "itunes:image@href"
        case itunesKeywords    = "itunes:keywords"
        case itunesSubtitle    = "itunes:subtitle"
        case itunesSummaryData = "itunes:summary@"
        case link
        case pubDate
        case title
    }
    
}
