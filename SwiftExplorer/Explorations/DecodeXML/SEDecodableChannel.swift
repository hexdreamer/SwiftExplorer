
import Foundation

public struct SEDecodableChannel : Decodable {

    let atomLink:URL?
    let copyright:String
    let description:String
    let docs:String?
    let generator:String?
    let language:String
    let lastBuildDate:Date
    let link:URL
    let managingEditor:String?
    let pubDate:Date?
    let title:String
    let itunesAuthor:String
    let itunesCategory:String
    let itunesExplicit:Bool
    let itunesImage:URL
    let itunesNewFeedURL:URL?
    let itunesSubtitle:String
    let itunesSummary:String?
    let itunesType:String?
    let items:[SEDecodableItem]
    
    enum CodingKeys: String, CodingKey, SEXMLCodingKey {
        case atomLink         = "atom:link"
        case copyright
        case description
        case docs
        case generator
        case language
        case lastBuildDate
        case link
        case managingEditor
        case pubDate
        case title
        case itunesAuthor     = "itunes:author"
        case itunesCategory   = "itunes:category"
        case itunesExplicit   = "itunes:explicit"
        case itunesImage      = "itunes:image"
        case itunesNewFeedURL = "itunes:new-feed-url"
        case itunesSubtitle   = "itunes:subtitle"
        case itunesSummary    = "itunes:summary"
        case itunesType       = "itunes:type"
        case items            = "item"
        
        var attribute:String? {
            switch self {
                case .itunesImage:
                    return "href"
                default:
                    return nil
            }
        }
    }

}
