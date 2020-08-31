
import Foundation

public struct Channel : Decodable {

    let atomLink:URL
    let copyright:String
    let description:String
    let docs:String
    let generator:String
    let language:String
    let lastbuilddate:Date
    let link:URL
    let managingeditor:String
    let pubdate:Date
    let title:String
    let itunesAuthor:String
    let itunesCategory:String
    let itunesExplicit:Bool
    let itunesImage:URL
    let itunesNewFeedURL:URL
    let itunesSubtitle:String
    let itunesSummary:String
    let itunesType:String
    
    enum CodingKeys: String, CodingKey {
        case atomLink         = "atom:link"
        case copyright
        case description
        case docs
        case generator
        case language
        case lastbuilddate
        case link
        case managingeditor
        case pubdate
        case title
        case itunesAuthor     = "itunes:author"
        case itunesCategory   = "itunes:category"
        case itunesExplicit   = "itunes:explicit"
        case itunesImage      = "itunes:image"
        case itunesNewFeedURL = "itunes:new-feed-url"
        case itunesSubtitle   = "itunes-subtitle"
        case itunesSummary    = "itunes:summary"
        case itunesType       = "itunes:type"
    }

}
