
import Foundation

struct SEDecodableItem : Decodable {
    
    let contentEncoded:String?
    let description:String
    let enclosure:String?
    let guid:String
    let itunesDuration:String
    let itunesEpisodeType:String?
    let itunesExplicit:Bool?
    let itunesImage:URL?
    let itunesKeywords:String?
    let itunesSubtitle:String
    let link:URL
    let pubDate:Date
    let title:String
    
    enum CodingKeys: String, CodingKey {
        case contentEncoded    = "content:encoded"
        case description
        case enclosure
        case guid
        case itunesDuration    = "itunes:duration"
        case itunesEpisodeType = "itunes:episodetype"
        case itunesExplicit    = "itunes:explicit"
        case itunesImage       = "itunes:image"
        case itunesKeywords    = "itunes:keywords"
        case itunesSubtitle    = "itunes:subtitle"
        case link
        case pubDate
        case title
    }
    
}
